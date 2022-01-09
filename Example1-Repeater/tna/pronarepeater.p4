/* -*- P4_16 -*- */
// ProNA P4 Repeater
#include <core.p4>
//BMv2 used #include <v1model.p4> here
#include <tna.p4>
struct headers { }
struct metadata { }

// Parser can stay empty, not necessary, protocol agnostic, working on physical layer/layer 1
parser MyIngressParser(packet_in pkt,
                       out headers hdr,
                       out metadata meta,
                       out ingress_intrinsic_metadata_t ig_intr_md) {
    state start{
        pkt.extract(ig_intr_md);
        pkt.advance(PORT_METADATA_SIZE);
        transition accept;
    }
}

control MyIngress(inout headers hdr, inout metadata meta, in ingress_intrinsic_metadata_t ig_intr_md, in ingress_intrinsic_metadata_from_parser_t ig_prsr_md, inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md, inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {
    apply {
        // forward all coming in from port 44 to port 45 and vice versa, use the device port D_P, as, e.g., displayed from "show -a" in ucli in bfshell
        if (ig_intr_md.ingress_port == 44) { ig_tm_md.ucast_egress_port = 45; }
        if (ig_intr_md.ingress_port == 45) { ig_tm_md.ucast_egress_port = 44; }
    }
}

control MyIngressDeparser(packet_out pkt, inout headers hdr, in metadata meta, in ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) { apply { pkt.emit(hdr); } }

parser MyEgressParser(packet_in pkt,
                      out headers hdr,
                      out metadata meta,
                      out egress_intrinsic_metadata_t eg_intr_md) {
    state start {
        pkt.extract(eg_intr_md);
        transition accept;
    }
}

// no further changes or adaption on outgoing data necessary, egress pipeline definition can stay empty
control MyEgress(inout headers hdr,
                 inout metadata meta,
                 in egress_intrinsic_metadata_t eg_intr_md,
                 in egress_intrinsic_metadata_from_parser_t eg_prsr_md,
                 inout egress_intrinsic_metadata_for_deparser_t eg_dprsr_md,
                 inout egress_intrinsic_metadata_for_output_port_t eg_oport_md) { apply { } }

// nothing changed, so no need to deparse (i.e., serialize) modified packet data like header fields
control MyEgressDeparser(packet_out pkt,
                       inout headers hdr,
                       in metadata meta,
                       in egress_intrinsic_metadata_for_deparser_t eg_dprsr_md) { apply { pkt.emit(hdr); } }


//V1Switch(MyParser(), MyVerifyChecksum(), MyIngress(), MyEgress(), MyComputeChecksum(), MyDeparser()) main;
Pipeline(MyIngressParser(), MyIngress(), MyIngressDeparser(), MyEgressParser(), MyEgress(), MyEgressDeparser()) pipe;
Switch(pipe) main;
