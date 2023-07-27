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
        self.net.setP4SourceAll('./p4src/prona-switch-learning.p4')
        # Add links between nodes
        self.net.addLink('h1','s1')
        self.net.addLink('h2','s2')
        self.net.addLink('s1','s2')
        self.net.addLink('s1','s3')
        self.net.addLink('h3','s3')
        self.net.addLink('h4','s3')
        '''
        # configure ip addresses from host to switch
        self.net.setIntfIp('h1', 's1', '10.0.10.10/24')
        self.net.setIntfMac('h1', 's1', '00:00:00:00:00:aa')
        self.net.setIntfIp('h11', 's1', '10.0.10.20/24')
        self.net.setIntfIp('s1', 'h1', '10.0.10.1/24')
        self.net.setIntfIp('h2', 's2', '10.0.20.10/24')
        self.net.setIntfMac('h2', 's2', '00:00:00:00:00:bb')
        self.net.setIntfIp('s2', 'h2', '10.0.20.1/24')
        self.net.setIntfIp('h3', 's3', '10.0.30.10/24')
        self.net.setIntfIp('s3', 'h3', '10.0.30.1/24')
        # configure ip addresses between switches
        self.net.setIntfIp('s1', 's3', '192.168.1.1/24')
        self.net.setIntfIp('s1', 's2', '192.168.3.254/24')
        self.net.setIntfIp('s2', 's1', '192.168.3.1/24')
        self.net.setIntfIp('s2', 's3', '192.168.2.254/24')
        self.net.setIntfIp('s3', 's1', '192.168.1.254/24')
        self.net.setIntfIp('s3', 's2', '192.168.2.1/24')
        '''
        self.net.mixed()
        self.net.enablePcapDumpAll()
        self.net.enableLogAll()
        
        
    
    def run(self):
        self.net.enableCli()
        self.net.startNetwork()


if __name__ == '__main__':
    topo = Example5Topology()
    topo.run()

