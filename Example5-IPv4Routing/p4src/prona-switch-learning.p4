/* -*- P4_16 -*- */
// ProNA Switch Learning
#include <core.p4>
#include <v1model.p4>

const bit<16> IPV4_ETHER_TYPE = 0x0800;

typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
    bit<4> version;
    bit<4> ipHeaderLen;
    bit<8> differentiatedServices;
    bit<16> totalLength;
    bit<16> identification;
    bit<3> flags;
    bit<13> fragmentOffset;
    bit<8> ttl;
    bit<8> protocol;
    bit<16> headerChecksum;
    ipv4Addr_t srcAddr;
    ipv4Addr_t destAddr;
    // options could go here, but are omitted.
}

struct headers {
    ethernet_t ethernet;
    ipv4_t ipv4;
}

// we need metadata now, that will carry over a value from ingress to egress
struct metadata {
}

// Parser can stay empty, not necessary, protocol agnostic, working on physical layer/layer 1
parser MyParser(packet_in pkt, out headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            IPV4_ETHER_TYPE: parse_ipv4;
            default: accept;
        }
    }
    
    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }
    
}

// we do not need to care or even know about checksums, can stay empty...
control MyVerifyChecksum(inout headers hdr, inout metadata meta) { apply { } }

// extend basic forwarding logic from previous example to include learning of MAC addresses and use it to achieve flood & filter
control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {

    action drop() {
        mark_to_drop(std_meta);
    }

    action ipv4_forward(macAddr_t dstAddr, bit<9> port) {
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        std_meta.egress_spec = port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.destAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    apply {
        if(hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
        }
    }
}

// send cloned packets to CPU/control plane, filter broadcasts going out on the port they came in
control MyEgress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    apply { }
}

// nothing changed that belongs to a checksum, so no need to calculate new checksums
control MyComputeChecksum(inout headers hdr, inout metadata meta) { 
    apply {
        update_checksum(
            hdr.ipv4.isValid(),
            {   hdr.ipv4.version,
                hdr.ipv4.ipHeaderLen,
                hdr.ipv4.differentiatedServices,
                hdr.ipv4.totalLength,
                hdr.ipv4.identification,
                hdr.ipv4.flags,
                hdr.ipv4.fragmentOffset,
                hdr.ipv4.ttl,
                hdr.ipv4.protocol,
                hdr.ipv4.srcAddr,
                hdr.ipv4.destAddr },
            hdr.ipv4.headerChecksum,
            HashAlgorithm.csum16);
    } 
 }

// need to deparse (i.e., serialize) extracted data and added headers (CPU header) to prepend them to outgoing packet
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
      pkt.emit(hdr.ethernet);
      pkt.emit(hdr.ipv4);
    }
}

V1Switch(MyParser(), 
         MyVerifyChecksum(), 
         MyIngress(), 
         MyEgress(), 
         MyComputeChecksum(), 
         MyDeparser()
) main;
