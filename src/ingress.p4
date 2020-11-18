#include "controls/IP.p4"

#include "controls/IP_FRR.p4"

#include "controls/ARP.p4"

#include "controls/Topology.p4"

#include "controls/Port.p4"

#include "controls/Port_Down.p4"

control ingress(
    inout header_t hdr,
    inout ingress_metadata_t ig_md, in ingress_intrinsic_metadata_t ig_intr_md, in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
    inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
    inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

    IP() ip_c;
    IP_FRR() ip_frr_c;
    ARP() arp_c;
    Topology() topology_c;
    Port() port_c;
    Port_Down() port_down_c;

    apply {

        // used to determine I2E processing 
        // will be overwritten in egress 
        hdr.ethernet.src_addr = ig_intr_md.ingress_mac_tstamp;

        ig_md.port_event = 2; // read port

        if (hdr.ethernet.ether_type == ETHERTYPE_TOPOLOGY) {
            topology_c.apply(hdr, ig_md, ig_intr_md, ig_tm_md);
            ig_md.port_event = 1; // port up event
        }
        else if (hdr.ethernet.ether_type == ETHERTYPE_IPV4 && hdr.ipv4.ttl > 0) {
            ip_c.apply(hdr, ig_md, ig_tm_md, ig_intr_md);
        }
        else if (hdr.ethernet.ether_type == TYPE_ARP) {
            arp_c.apply(hdr, ig_intr_md, ig_tm_md);
        }
        else if (hdr.ethernet.ether_type == ETHERTYPE_PORT_DOWN) { // send port down packets to controller
            port_down_c.apply(hdr, ig_intr_md, ig_md, ig_tm_md, ig_dprsr_md);
        }

        port_c.apply(hdr, ig_intr_md, ig_md, ig_tm_md, ig_dprsr_md);

        if (ig_tm_md.ucast_egress_port > 0 && ig_tm_md.ucast_egress_port != RECIRCULATE_PORT) {
            if(ig_md.port_status == 0 && hdr.ethernet.ether_type == ETHERTYPE_IPV4) {

              if(hdr.ipv4.diffserv < 200 && hdr.ipv4.ttl > 0) {
                ip_frr_c.apply(hdr, ig_md, ig_tm_md, ig_intr_md);

                hdr.ipv4.diffserv = hdr.ipv4.diffserv + 1;


                if(hdr.ipv4_inner.isValid()) {
                  hdr.ipv4_inner.protocol = 6;
                }
                else {
                  hdr.ipv4.protocol = 6;
            }
          }
        }
      }
    }
}
