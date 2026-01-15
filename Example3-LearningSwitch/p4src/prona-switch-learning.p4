/* -*- P4_16 -*- */
// ProNA Switch Learning
#include <core.p4>
#include <v1model.p4>

#define TABLE_SIZE_L2_FORWARDING 1024
const bit<16> L2_LEARN_ETHER_TYPE = 0x4221;
const bit<32> MIRROR_SESSION_ID = 99;
const bit<8> CLONE_FL_1 = 2;

typedef bit<48> macAddr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

// cpu header prepended to packets going to the CPU, containing source MAC address to learn and ingress port
header cpu_t {
    bit<48> srcAddr;
    bit<16> ingressPort;
}

struct headers {
    ethernet_t ethernet;
    cpu_t cpu;
}

// we need metadata now, that will carry over a value from ingress to egress
struct metadata {
    @field_list(CLONE_FL_1)
    bit<9> ingressPort;
}

// Parser to extract ethernet header, switch is working on data link layer/layer 2
parser MyParser(packet_in pkt, out headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    state start{
        pkt.extract(hdr.ethernet);
        transition accept;
    }
}

// we do not need to care or even know about checksums, can stay empty...
control MyVerifyChecksum(inout headers hdr, inout metadata meta) { apply { } }

// extend basic forwarding logic from previous example to include learning of MAC addresses and use it to achieve flood & filter
control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    // action to learn source MAC address, copy ingress_port to be available in egress, clone packet to CPU port (ingress to egress)
    action learnSrcMacAddr() {
        meta.ingressPort = std_meta.ingress_port;
        clone_preserving_field_list(CloneType.I2E, MIRROR_SESSION_ID, CLONE_FL_1);
    }

    // source MAC address table, if source MAC address matches, do nothing, otherwise send MAC address to CPU port to get learned
    table srcMacAddr {
        key = {
            hdr.ethernet.srcAddr: exact;
        }

        actions = {
            learnSrcMacAddr;
            NoAction;
        }
        size = TABLE_SIZE_L2_FORWARDING;
        default_action = learnSrcMacAddr;
    }

    // action to forward packet to egress port
    action forward(bit<9> egress_port) {
        std_meta.egress_spec = egress_port;
    }

    // action to broadcast packet (e.g., when destination MAC address is unknown or broadcast/multicast address)
    action broadcast() {
        std_meta.mcast_grp = 1;
    }

    // destination MAC address table, if destination mac address matches, specified action will be applied
    table dstMacAddr {
        key = {
            hdr.ethernet.dstAddr: exact;
        }

        actions = {
            forward;
            broadcast;
        }
        size = TABLE_SIZE_L2_FORWARDING;
        default_action = broadcast;
    }

    apply {
        srcMacAddr.apply();
        dstMacAddr.apply();
    }
}

// send cloned packets to CPU/control plane, filter broadcasts going out on the port they came in
control MyEgress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    apply {
        // if packet was cloned (instance_type == 1)
        if (std_meta.instance_type == 1){
            // populate cpu header
            hdr.cpu.setValid();
            hdr.cpu.srcAddr = hdr.ethernet.srcAddr;
            // ports in bmv2 use bit<9> but CPU header uses 2 (full) bytes for port, therefore cast to bit<16>
            hdr.cpu.ingressPort = (bit<16>)meta.ingressPort;
            // set ether_type to custom value defined for our app
            hdr.ethernet.etherType = L2_LEARN_ETHER_TYPE;
            truncate((bit<32>)22);  // get only start of packet - Ethernet (14 bytes) + CPU Header (8 bytes)
        }
        else
        {
            // if packet is going to a multicast group (i.e., is a broadcast or multicast)
            if (std_meta.mcast_grp == 1)
            {
                // if egress port is the same as the ingress port stored in meta from ingress
                // for v1model, however, also std_meta.egress_port == std_meta.ingress_port seams to work
                if (std_meta.egress_port == meta.ingressPort)
                {
                    mark_to_drop(std_meta);
                }
            }
        }
    }
}

// nothing changed that belongs to a checksum, so no need to calculate new checksums
control MyComputeChecksum(inout headers hdr, inout metadata meta) { apply { } }

// need to deparse (i.e., serialize) extracted data and added headers (CPU header) to prepend them to outgoing packet
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
      pkt.emit(hdr.ethernet);
      pkt.emit(hdr.cpu);
    }
}

V1Switch(MyParser(), 
         MyVerifyChecksum(), 
         MyIngress(), 
         MyEgress(), 
         MyComputeChecksum(), 
         MyDeparser()
) main;
