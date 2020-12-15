/* -*- P4_16 -*- */
// ProNA P4 Boilerplate
#include <core.p4>
#include <v1model.p4>

struct headers {
}

struct metadata {
}

// Parser
parser MyParser(packet_in pkt,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t std_meta) {

    state start{ transition accept; }
}

// Match-Action
control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t std_meta) {
    apply { }
}

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t std_meta) {
    apply { }
}

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
    apply { }
}

// Deparser
control MyDeparser(packet_out pkt, in headers hdr) {
    apply { }
}

// V1Model/BMv2 architecture
V1Switch(MyParser(),
         MyVerifyChecksum(),
         MyIngress(),
         MyEgress(),
         MyComputeChecksum(),
         MyDeparser()
) main;