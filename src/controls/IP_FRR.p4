control IP_FRR(inout header_t hdr, in ingress_metadata_t ig_md, inout ingress_intrinsic_metadata_for_tm_t ig_tm_md, in ingress_intrinsic_metadata_t ig_intr_md) {

    action lfa(PortId_t e_port) {
        ig_tm_md.ucast_egress_port = e_port;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    // represents e/rlfa --> tlfa (topology lfa)
    action tlfa(PortId_t e_port, ipv4_addr_t src_ip, ipv4_addr_t dst_ip) {
      hdr.ipv4_inner.setValid();
      hdr.ipv4_inner = hdr.ipv4;
      hdr.ipv4.src_addr = src_ip;
      hdr.ipv4.dst_addr = dst_ip;
      hdr.ipv4.protocol = TYPE_IP;

      ig_tm_md.ucast_egress_port = e_port;
    }

    table frr {
        key = {
            hdr.ipv4.dst_addr: exact;
            ig_tm_md.ucast_egress_port: exact;
        }
        actions = {
          lfa;
          tlfa;
        }
    }

    apply {
        frr.apply();
    }
}
