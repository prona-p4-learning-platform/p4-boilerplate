#include <core.p4>
#include <v1model.p4>

typedef bit<16> etherType_t;
typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;

const etherType_t IPV4_ETHER_TYPE = 0x0800;
const etherType_t MPLS_ETHER_TYPE = 0x8847;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    etherType_t ethertype;
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

header mplsLabel_t {
    bit<20> label;
    bit<3> trafficClass;
    bit<1> bottomOfStack;
    bit<8> ttl;
}

struct Headers {
    ethernet_t ethernet;
    ipv4_t ipv4;
    mplsLabel_t mpls;
}

// Metadata can stay empty
struct Metadata {
}

parser MyParser(packet_in pkt, out Headers hdr, inout Metadata meta, inout standard_metadata_t std_meta) {
    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ethertype) {
            IPV4_ETHER_TYPE: parse_ipv4;
            MPLS_ETHER_TYPE: parse_mpls;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }

    state parse_mpls {
        pkt.extract(hdr.mpls);
        transition parse_ipv4;
    }
}

control MyVerifyChecksum(inout Headers hdr, inout Metadata meta) { apply { } }

control MyIngress(inout Headers hdr, inout Metadata meta, inout standard_metadata_t std_meta) {
    apply {}
}

control MyEgress(inout Headers hdr, inout Metadata meta, inout standard_metadata_t std_meta) {
    apply {}
}

control MyComputeChecksum(inout Headers hdr, inout Metadata meta) {
    apply { }
}

control MyDeparser(packet_out pkt, in Headers hdr) {
    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.mpls);
        pkt.emit(hdr.ipv4);
    }
}

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;



