/* -*- P4_16 -*- */
// ProNA Switch Static Naive
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

// Parser to extract ethernet header, switch is working on data link layer/layer 2
parser MyParser(packet_in pkt, out headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    state start{
        pkt.extract(hdr.ethernet);
        transition accept;
    }
}

// we do not need to care or even know about checksums, can stay empty...
control MyVerifyChecksum(inout headers hdr, inout metadata meta) { apply { } }

control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t std_meta) {
    apply {
        // forward all packets going to mac address of H1 to port 1, same for H2 and port 2
        if (hdr.ethernet.dstAddr == 0x00000a000001) { std_meta.egress_spec = 1; }
        if (hdr.ethernet.dstAddr == 0x00000b000002) { std_meta.egress_spec = 2; }
    }
}

// no further changes or adaption on outgoing data necessary, egress pipeline definition can stay empty
control MyEgress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) { apply { } }

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
