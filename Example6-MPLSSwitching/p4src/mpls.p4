#include <core.p4>
#include <v1model.p4>

typedef bit<16> etherType_t;
typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;

const etherType_t IPV4_ETHER_TYPE = 0x0800;
const etherType_t MPLS_ETHER_TYPE = 0x8847;
const bit<3> TRAFFIC_CLASS_IP = 0b001;

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
    // specifies which type of protocol this packet contains
    bit<3> trafficClass;
    // When using multiple labels, this could signal that this is the last label in the stack.
    // Currently unused because only one label is supplied
    bit<1> bos;
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
        transition select(hdr.mpls.trafficClass) {
            TRAFFIC_CLASS_IP: parse_ipv4;
            default: accept;
        }
    }
}

control MyVerifyChecksum(inout Headers hdr, inout Metadata meta) { apply { } }

control MyIngress(inout Headers hdr, inout Metadata meta, inout standard_metadata_t std_meta) {

    action drop() {
        mark_to_drop(std_meta);
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        std_meta.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    action mpls_forward(egressSpec_t port) {
        std_meta.egress_spec = port;
    }

    table mpls_exact {
        key = {
            hdr.mpls.label: exact;
        }
        actions = {
            mpls_forward;
            drop;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        if(hdr.ipv4.isValid() && !hdr.mpls.isValid()) {
            ipv4_lpm.apply();
        }

        if(hdr.mpls.isValid()) {
            mpls_exact.apply();
        }
    }
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



