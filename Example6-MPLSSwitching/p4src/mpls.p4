#include <core.p4>
#include <v1model.p4>

typedef bit<16> etherType_t;
typedef bit<9> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ipv4Addr_t;

const etherType_t IPV4_ETHER_TYPE = 0x0800;
const etherType_t MPLS_ETHER_TYPE = 0x8847;
const bit<4> TRAFFIC_CLASS_IP = 0b001;

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
    // Label which decides the path the packet will take
    bit<20> label;
    // specifies which type of protocol this packet contains
    bit<4> trafficClass;
    // ttl in order to prevent loops
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

    // perform basic ipv4 forwarding
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        std_meta.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    // this action adds a mpls label to a packet and sends it on its way
    action mpls_begin(bit<20> label, egressSpec_t port) {
        hdr.ethernet.ethertype = MPLS_ETHER_TYPE;
        hdr.mpls.setValid();
        hdr.mpls.label = label;
        hdr.mpls.trafficClass = TRAFFIC_CLASS_IP;
        hdr.mpls.ttl = 15;
        std_meta.egress_spec = port;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.destAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            mpls_begin;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    // Forward based on label
    action mpls_forward(egressSpec_t port) {
        std_meta.egress_spec = port; 
        hdr.mpls.ttl = hdr.mpls.ttl - 1;
    }

    // same as mpls_forward, but removes the mpls header and sets the
    // ethertype to IPv4
    action mpls_end(egressSpec_t port) {
        // invalidate the mpls header
        hdr.mpls.setInvalid();
        // set ethertype to ip
        hdr.ethernet.ethertype = IPV4_ETHER_TYPE;
        // send out to port specified in table
        std_meta.egress_spec = port;
    }

    table mpls_exact {
        key = {
            std_meta.ingress_port: exact;
            hdr.mpls.label: exact;
        }
        actions = {
            mpls_forward;
            mpls_end;
            drop;
        }
        size = 1024;
        default_action = drop();
    }

    apply {
        if(hdr.mpls.isValid()) {
            mpls_exact.apply();
        } else {
            ipv4_lpm.apply();
        }
    }
}

control MyEgress(inout Headers hdr, inout Metadata meta, inout standard_metadata_t std_meta) {
    apply {}
}

control MyComputeChecksum(inout Headers hdr, inout Metadata meta) {
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



