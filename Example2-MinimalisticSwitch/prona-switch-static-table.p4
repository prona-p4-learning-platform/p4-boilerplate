/* -*- P4_16 -*- */
// ProNA Switch Static Table
#include <core.p4>
#include <v1model.p4>

typedef bit<48> macAddr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

struct headers {
    ethernet_t ethernet;
}

struct metadata { }

// Parser to extract ethernet header, switch is working on data link layer/layer 2
parser MyParser(packet_in pkt, out headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    state start{
        pkt.extract(hdr.ethernet);
        transition accept;
    }
}

// we do not need to care or even know about checksums, can stay empty...
control MyVerifyChecksum(inout headers hdr, inout metadata meta) { apply { } }

// use a MAC address table to decide where to forward packets (layer 2 forwarding/filtering) and also support broadcasts (layer 2 flooding)
control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    // action to forward packet to egress port
    action forward(bit<9> egress_port) {
        std_meta.egress_spec = egress_port;
    }

    // action to broadcast packet (e.g., when destination MAC address is unknown or broadcast/multicast address)
    action broadcast() {
        std_meta.mcast_grp = 1;
    }

    // MAC address table, if destination mac address matches, specified action will be applied
    table dstMacAddr {
        key = {
            hdr.ethernet.dstAddr: exact;
        }

        actions = {
            forward;
            broadcast;
        }
        size = 4096;
        default_action = broadcast;
    }

    apply {
        dstMacAddr.apply();
    }
}

// filter broadcasts going out on the port they came in
control MyEgress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    apply {
        // if packet is going to a multicast group (i.e., is a broadcast or multicast)
        if (std_meta.mcast_grp == 1)
        {
            // if egress port is the same as the ingress port
            if (std_meta.egress_port == std_meta.ingress_port)
            {
                mark_to_drop(std_meta);
            }
        }
    }
}

// nothing changed that belongs to a checksum, so no need to calculate new checksums
control MyComputeChecksum(inout headers hdr, inout metadata meta) { apply { } }

// need to deparse (i.e., serialize) extracted data to prepend it to outgoing packet
control MyDeparser(packet_out pkt, in headers hdr) {
    apply {
      pkt.emit(hdr.ethernet);
    }
}

V1Switch(MyParser(), 
         MyVerifyChecksum(), 
         MyIngress(), 
         MyEgress(), 
         MyComputeChecksum(), 
         MyDeparser()
) main;
