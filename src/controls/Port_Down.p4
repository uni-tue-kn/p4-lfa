control Port_Down(inout header_t hdr, in ingress_intrinsic_metadata_t ig_intr_md, inout ingress_metadata_t ig_md, inout ingress_intrinsic_metadata_for_tm_t ig_tm_md, inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md) {
    apply {
        ig_md.port_event = 0;

        if (ig_intr_md.ingress_port == RECIRCULATE_PORT || ig_intr_md.ingress_port == DECAP_PORT) {
            ig_tm_md.ucast_egress_port = CPU_PORT;
        }
        else {
            if (ig_intr_md.ingress_port < 128) {
                ig_tm_md.ucast_egress_port = RECIRCULATE_PORT;
            }
            else {
                ig_tm_md.ucast_egress_port = DECAP_PORT;
            }
        }
    }
}
