require 'manageiq/network_discovery/port'

module ManageIQ::Providers::Openstack
  class Discovery
    IRONIC_PORTS = [13385, 6385]

    def self.probe(ost)
      # Openstack InfraManager (TripleO/Director) discovery
      IRONIC_PORTS.each do |port|
        if ManageIQ::NetworkDiscovery::Port.open?(ost, port)
          res = ''
          Socket.tcp(ost.ipaddr, port) do |s|
            s.print("GET / HTTP/1.0\r\n\r\n")
            s.close_write
            res = s.read
          end
          if res =~ /OpenStack Ironic API/
            ost.hypervisor << :openstack_infra
            break
          end
        end
      end
    end
  end
end
