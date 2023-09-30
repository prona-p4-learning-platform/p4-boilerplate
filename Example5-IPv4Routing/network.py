from p4utils.mininetlib.network_API import NetworkAPI

class Example5Topology(object):

    def __init__(self):
        self.net = NetworkAPI()
        # Add P4 Switches to network
        self.net.addP4Switch('s1', cli_input='commands-s1.txt')
        self.net.addP4Switch('s2', cli_input='commands-s2.txt')
        self.net.addP4Switch('s3')
        # Add Hosts to network
        self.net.addHost('h1')
        self.net.addHost('h2')
        self.net.addHost('h3')
        self.net.addHost('h4')
        # Set the same P4 program for all switches
        self.net.setP4SourceAll('./p4src/ipv4_routing.p4')
        # Add links between nodes
        self.net.addLink('h1','s1')
        self.net.addLink('h2','s2')
        self.net.addLink('s1','s2')
        self.net.addLink('s1','s3')
        self.net.addLink('h3','s3')
        self.net.addLink('h4','s3')

        self.net.mixed()
        self.net.enablePcapDumpAll()
        self.net.enableLogAll()
        
        
    
    def run(self):
        self.net.enableCli()
        self.net.startNetwork()


if __name__ == '__main__':
    topo = Example5Topology()
    topo.run()

