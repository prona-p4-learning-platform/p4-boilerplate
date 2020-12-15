/* -*- P4_16 -*- */
// ProNA P4 Repeater
#include <core.p4>
#include <v1model.p4>
struct headers { }
struct metadata { }

// Parser can stay empty, not necessary, protocol agnostic, working on physical layer/layer 1
parser MyParser(packet_in pkt, out headers hdr, inout metadata meta, inout standard_metadata_t std_meta) { state start{ transition accept; } }

// we do not know about protocols, we do not need to care or even know about checksums, can stay empty...
control MyVerifyChecksum(inout headers hdr, inout metadata meta) { apply { } }

control MyIngress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
        // forward all coming in from port 1 to port 2 and vice versa
        if (standard_metadata.ingress_port == 1) { standard_metadata.egress_spec = 2; }
        if (standard_metadata.ingress_port == 2) { standard_metadata.egress_spec = 1; }
    }
}

// no further changes or adaption on outgoing data necessary, egress pipeline definition can stay empty
control MyEgress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) { apply { } }

// nothing changed, so no need to calculate new checksums or deparse (i.e., serialize) modified packet data like header fields
control MyComputeChecksum(inout headers hdr, inout metadata meta) { apply { } }
control MyDeparser(packet_out packet, in headers hdr) { apply { } }

V1Switch(MyParser(), MyVerifyChecksum(), MyIngress(), MyEgress(), MyComputeChecksum(), MyDeparser()) main;
