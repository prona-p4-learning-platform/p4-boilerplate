from p4utils.mininetlib.network_API import NetworkAPI

class Example6Topo(object):

    def __init__(self):
        self.network = NetworkAPI()
        # add P4 Switches to Network Topology
        for i in range(5):
            self.network.addP4Switch('s' + str((i + 1)))
        # add two hosts to the Networks Topology
        for i in range(3):
            self.network.addHost('h' + str((i + 1)))
        self.network.setP4SourceAll('./p4src/mpls.p4')
        self.network.mixed()

        # connect the network components as specified by the diagram in README.md
        self.network.addLink('h1', 's1')
        self.network.addLink('s1', 's2')
        self.network.addLink('s1', 's4')
        self.network.addLink('s2', 's3')
        self.network.addLink('s3', 'h2')
        self.network.addLink('s4', 's5')
        self.network.addLink('s5', 'h3')

        # enable pcaps and logging
        self.network.enablePcapDumpAll()
        self.network.enableLogAll()
    
    def run(self):
        self.network.enableCli()
        self.network.startNetwork()

if __name__ == '__main__':
    Example6Topo().run()
