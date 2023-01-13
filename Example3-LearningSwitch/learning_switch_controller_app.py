from p4utils.utils.helper import load_topo
from p4utils.utils.sswitch_thrift_API import SimpleSwitchThriftAPI
from scapy.all import Ether, sniff, Packet, BitField, raw

L2_LEARN_ETHER_TYPE = 0x4221
MIRROR_SESSION_ID = 99


class CpuHeader(Packet):
    name = 'CpuPacket'
    fields_desc = [BitField('srcAddr', 0, 48), BitField('ingressPort', 0, 16)]


class LearningSwitchControllerApp(object):

    def __init__(self, sw_name):
        self.topo = load_topo('topology.json')
        self.switchName = sw_name
        self.thriftPort = self.topo.get_thrift_port(sw_name)
        self.cpuPort = self.topo.get_cpu_port_index(self.switchName)
        self.controller = SimpleSwitchThriftAPI(self.thriftPort)
        self.init()

    def init(self):
        self.controller.reset_state()
        self.add_boadcast_group()
        self.add_mirror()
        # uncomment the following line to prefill dstMacAddr table
        # self.fill_table_test()

    def add_mirror(self):
        if self.cpuPort:
            self.controller.mirroring_add(MIRROR_SESSION_ID, self.cpuPort)

    def add_boadcast_group(self):
        interfaces_to_port = self.topo.get_node_intfs(fields=['port'])[
            self.switchName].copy()
        # filter lo and cpu port
        interfaces_to_port.pop('lo', None)
        interfaces_to_port.pop(self.topo.get_cpu_port_intf(self.switchName), None)

        # add multicast group
        mc_grp_id = 1
        rid = 0
        # get all ports to add them to multicast group (default broadcast),
        # ingress port is filtered for outgoing/egress traffic in P4 code
        port_list = list(interfaces_to_port.values())
        # add multicast group
        self.controller.mc_mgrp_create(mc_grp_id)
        # add multicast node group
        handle = self.controller.mc_node_create(rid, port_list)
        # associate with mc grp
        self.controller.mc_node_associate(mc_grp_id, handle)

    def fill_table_test(self):
        self.controller.table_add("dstMacAddr", "forward", [
                                  '00:00:0a:00:00:01'], ['1'])
        self.controller.table_add("dstMacAddr", "forward", [
                                  '00:00:0a:00:00:02'], ['2'])
        self.controller.table_add("dstMacAddr", "forward", [
                                  '00:00:0a:00:00:03'], ['3'])

    def learn(self, learning_data):
        for srcAddr, ingressPort in learning_data:
            print("srcAddr: %012X ingressPort: %s " % (srcAddr, ingressPort))
            self.controller.table_add(
                "srcMacAddr", "NoAction", [str(srcAddr)])
            self.controller.table_add(
                "dstMacAddr", "forward", [str(srcAddr)], [str(ingressPort)])

    def recv_msg_cpu(self, pkt):
        packet = Ether(raw(pkt))
        if packet.type == L2_LEARN_ETHER_TYPE:
            cpu_header = CpuHeader(bytes(packet.load))
            self.learn([(cpu_header.srcAddr, cpu_header.ingressPort)])

    def run_cpu_port_loop(self):
        cpu_port_intf = str(self.topo.get_cpu_port_intf(
            self.switchName).replace("eth0", "eth1"))
        sniff(iface=cpu_port_intf, prn=self.recv_msg_cpu)


if __name__ == "__main__":
    import sys
    switchName = sys.argv[1]
    controller = LearningSwitchControllerApp(switchName).run_cpu_port_loop()
