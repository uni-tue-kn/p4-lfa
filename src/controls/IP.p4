control IP(inout header_t hdr, inout ingress_metadata_t ig_md, inout ingress_intrinsic_metadata_for_tm_t ig_tm_md, in ingress_intrinsic_metadata_t ig_intr_md) {

    action decap() {
        // ToDo 
        // move loop detection bit to inner header 

        bit<8> diff = hdr.ipv4.diffserv;
        hdr.ipv4 = hdr.ipv4_inner; // move inner header to outer --> decap outer

        hdr.ipv4.diffserv = diff;

        hdr.ipv4_inner.setInvalid();
    }

    action forward(PortId_t e_port) {
        ig_tm_md.ucast_egress_port = e_port;
    }

    table ip_decap {
      key = {
        hdr.ipv4.dst_addr: exact;
      }
      actions = {
        decap;
      }

    }

    table ip {
        key = {
            hdr.ipv4.dst_addr: lpm;
        }
        actions = {
            forward;
        }
    }

    apply {
      ip_decap.apply(); // first decap if possible --> covers e/rlfa decap
      ip.apply(); // then do normal forward --> covers normal forward, e/rlfa forward
    }
}
