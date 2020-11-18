#include "controls/Mac.p4"


control egress(
    inout header_t hdr,
    inout egress_metadata_t eg_md, in egress_intrinsic_metadata_t eg_intr_md, in egress_intrinsic_metadata_from_parser_t eg_intr_from_prsr,
    inout egress_intrinsic_metadata_for_deparser_t eg_intr_md_for_dprsr,
    inout egress_intrinsic_metadata_for_output_port_t eg_intr_md_for_oport) {

    Mac() mac_c;

    apply {
      bit<48> time = eg_intr_from_prsr.global_tstamp;
      if(hdr.ipv4_inner.isValid()) {
        hdr.ipv4_inner.src_addr = (bit<32>) (time - hdr.ethernet.src_addr);
      }
      else {
        if(hdr.ipv4.isValid()) {
          hdr.ipv4.src_addr = (bit<32>) (time - hdr.ethernet.src_addr);
        }
      }
        mac_c.apply(hdr, eg_intr_md);
    }
}
