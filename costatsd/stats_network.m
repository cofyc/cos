#include "stats.h"
#include "wrapper.h"

#include <pthread.h>
#include <pcap.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/in.h>
#include <unistd.h>
#include <netinet/tcp.h>
#include <netinet/if_ether.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>

struct vlan_8021q_header {
    u_int16_t priority_cfi_vid;
    u_int16_t ether_type;
};

static pcap_t *handle = NULL;

struct in_addr if_addr;

static unsigned long int out_previous;
static unsigned long int in_previous;
static unsigned long int out_current;
static unsigned long int in_current;

static void
ip_packet_handler(struct ip* iptr)
{
    int len;

    len = ntohs(iptr->ip_len);
    if (if_addr.s_addr == iptr->ip_src.s_addr) {
        out_current += len;
    } else if (if_addr.s_addr == iptr->ip_dst.s_addr) {
        in_current += len;
    } else {
        return;
    }
}

static void
eth_packet_handler(u_char *args, const struct pcap_pkthdr *header, const u_char *packet)
{
    struct ether_header *eptr;
    int ether_type;
    const unsigned char *payload;
    eptr = (struct ether_header*)packet;
    ether_type = ntohs(eptr->ether_type);
    
    payload = packet + sizeof(struct ether_header);

    if (ether_type == ETHERTYPE_VLAN) {
        struct vlan_8021q_header* vptr;
        vptr = (struct vlan_8021q_header*)payload;
        ether_type = ntohs(vptr->ether_type);
        payload += sizeof(struct vlan_8021q_header);
    }

    if (ether_type == ETHERTYPE_IP) {
        struct ip* iptr;
        iptr = (struct ip*)payload;
        ip_packet_handler(iptr);
    }
}

static int
get_ip_address(const char *name, struct in_addr *addr)
{
    struct ifaddrs *addrs, *iap;
    struct sockaddr_in *sa;

    getifaddrs(&addrs);
    for (iap = addrs; iap != NULL; iap = iap->ifa_next) {
        if (iap->ifa_addr && (iap->ifa_flags & IFF_UP) && iap->ifa_addr->sa_family == AF_INET) {
            sa = (struct sockaddr_in *)(iap->ifa_addr);
            if (!strcmp(iap->ifa_name, name)) {
                memcpy(addr, &sa->sin_addr, sizeof(struct in_addr));
                return 0;
            }
        }
    }
    freeifaddrs(addrs);
    return -1;
}

static void *
setup_capture(void *arg)
{
    char *dev = NULL;
    char errbuf[PCAP_ERRBUF_SIZE];
    bpf_u_int32 mask;
    bpf_u_int32 net;

    if (dev == NULL) {
        // auto
        pcap_if_t *alldevs;
        pcap_if_t *d;
        if (pcap_findalldevs(&alldevs, errbuf) == -1) {
            return -1;
        }

        for (d = alldevs; d != NULL; d = d->next) {
            if (d->flags & PCAP_IF_LOOPBACK) {
            } else {
                dev = xstrndup(d->name, strlen(d->name));
            }
        }
        pcap_freealldevs(alldevs);
        dev = "en1";
    }

    if (pcap_lookupnet(dev, &net, &mask, errbuf) == -1) {
        net = 0;
        mask = 0;
    }

    get_ip_address(dev, &if_addr);

    handle = pcap_open_live(dev, BUFSIZ, 1, 1000, errbuf);
    if (handle == NULL) {
        return 2;
    }

    pcap_handler packet_handler;
    int dlt = pcap_datalink(handle);
    if (dlt == DLT_EN10MB) {
        packet_handler = eth_packet_handler;
    } else {
        return -2;
    }

    pcap_loop(handle, -1, packet_handler, NULL);
    
    /* And close the session */
    pcap_close(handle);

    return 0;
}

int
stats_network(struct stats_struct *stats)
{
    if (handle == NULL) {
        // init
        in_current = out_current = 0;
        in_previous = out_previous = 0;
        pthread_t tid;
        int err;
        err = pthread_create(&tid, NULL, setup_capture, NULL);
    }

    stats->network_in = in_current - in_previous;
    stats->network_out = out_current - out_previous;
    in_previous = in_current;
    out_previous = out_current;
    
    return 0;
}
