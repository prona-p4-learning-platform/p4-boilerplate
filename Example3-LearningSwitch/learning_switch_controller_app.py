from p4utils.utils.topology import Topology
from p4utils.utils.sswitch_API import SimpleSwitchAPI
from scapy.all import Ether, sniff, Packet, BitField

L2_LEARN_ETHER_TYPE = 0x4221
MIRROR_SESSION_ID = 99


class CpuHeader(Packet):
    name = 'CpuPacket'
    fields_desc = [BitField('macAddr', 0, 48), BitField('ingressPort', 0, 16)]


class LearningSwitchControllerApp(object):

    def __init__(self, switchName):
        self.topo = Topology(db="topology.db")
        self.switchName = switchName
        self.thrift_port = self.topo.get_thrift_port(switchName)
        self.cpu_port = self.topo.get_cpu_port_index(self.switchName)
        self.controller = SimpleSwitchAPI(self.thrift_port)

        self.init()

    def init(self):
        self.controller.reset_state()
        self.add_mcast_grp()
        self.add_mirror()

    def add_mirror(self):
        if self.cpu_port:
            self.controller.mirroring_add(MIRROR_SESSION_ID, self.cpu_port)

    def add_mcast_grp(self):
        interfaces_to_port = self.topo[self.switchName]["interfaces_to_port"].copy()
        # filter lo and cpu port
        interfaces_to_port.pop('lo', None)
        interfaces_to_port.pop(self.topo.get_cpu_port_intf(self.switchName), None)

        mc_grp_id = 1
        rid = 0
        # add multicast group
        self.controller.mc_mgrp_create(mc_grp_id)
        port_list = interfaces_to_port.values()[:]
        # add multicast node group
        handle = self.controller.mc_node_create(rid, port_list)
        # associate with mc grp
        self.controller.mc_node_associate(mc_grp_id, handle)

    def learn(self, learningData):
        for macAddr, ingressPort in learningData:
            print "macAddr: %012X ingressPort: %s " % (macAddr, ingressPort)
            self.controller.table_add("srcMacAddr", "NoAction", [str(macAddr)])
            self.controller.table_add("dstMacAddr", "forward", [
                                      str(macAddr)], [str(ingressPort)])

    def recv_msg_cpu(self, pkt):

        packet = Ether(str(pkt))
        if packet.type == L2_LEARN_ETHER_TYPE:
            cpu_header = CpuHeader(bytes(packet.payload))
            self.learn([(cpu_header.macAddr, cpu_header.ingressPort)])

    def run_cpu_port_loop(self):

        cpu_port_intf = str(self.topo.get_cpu_port_intf(
            self.switchName).replace("eth0", "eth1"))
        sniff(iface=cpu_port_intf, prn=self.recv_msg_cpu)


if __name__ == "__main__":
    import sys
    switchName = sys.argv[1]
    controller = LearningSwitchControllerApp(switchName).run_cpu_port_loop()
