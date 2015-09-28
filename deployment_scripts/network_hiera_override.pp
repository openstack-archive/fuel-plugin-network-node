notice('MODULAR: network-node/network_hiera_override.pp')

$network_node_plugin = hiera('network-node', undef)
$hiera_dir = '/etc/hiera/override'
$plugin_name = 'network-node'
$plugin_yaml = "${plugin_name}.yaml"

if $network_node_plugin {
  $network_metadata = hiera_hash('network_metadata')
  $network_roles = ['primary-network-node', 'network-node']
  $network_nodes = get_nodes_hash_by_roles($network_metadata, $network_roles)
  $management_vip = $network_metadata['vips']['management']['ipaddr']
  $public_vip = $network_metadata['vips']['public']['ipaddr']

  $quantum_hash = hiera_hash('quantum_settings')

  case hiera_array('role', 'none') {
    /network-node/: {

      if hiera('role', 'none') == 'primary-network-node' {
        $primary_controller = true
      } else {
        $primary_controller = false
      }
      $use_neutron = true
      $corosync_roles = $network_roles
      $deploy_vrouter = false
      $haproxy_nodes = false
      $corosync_nodes = $network_nodes
      $new_quantum_settings_hash = {
        'neutron_agents' => ['l3', 'metadata', 'dhcp'],
        'neutron_server_enable' => false,
        'conf_nova' => false
      }
      $neutron_settings = merge($quantum_hash, $new_quantum_settings_hash)
    }
    /controller/: {
      $use_neutron = true
      $new_quantum_settings_hash = {
        'neutron_agents' => [''],
      }
      $neutron_settings = merge($quantum_hash, $new_quantum_settings_hash)

      if hiera('role', 'none') =~ /^primary/ {
        $primary_controller = 'true'
      } else {
        $primary_controller = 'false'
      }
    }
    default: {
      $use_neutron = true
    }
  }

###################
  $calculated_content = inline_template('
<% if @corosync_nodes -%>
<% require "yaml" -%>
corosync_nodes:
<%= YAML.dump(@corosync_nodes).sub(/--- *$/,"") %>
<% end -%>
<% if @corosync_roles -%>
corosync_roles:
<%
@corosync_roles.each do |crole|
%>  - <%= crole %>
<% end -%>
<% end -%>
<% if @neutron_settings -%>
<% require "yaml" -%>
quantum_settings:
<%= YAML.dump(@neutron_settings).sub(/--- *$/,"") %>
<% end -%>
deploy_vrouter: <%= @deploy_vrouter %>
primary_controller: <%= @primary_controller %>
management_vip: <%= @management_vip %>
database_vip:  <%= @management_vip %>
service_endpoint: <%= @management_vip %>
public_vip: <%= @public_vip %>
use_neutron: <%= @use_neutron %>
  ')

###################

  file {'/etc/hiera/override':
    ensure  => directory,
  } ->
  file { '/etc/hiera/override/common.yaml':
    ensure  => file,
    content => "${calculated_content}\n",
  }

  package {'ruby-deep-merge':
    ensure  => 'installed',
  }

  file_line {'hiera.yaml':
    path  => '/etc/hiera.yaml',
      line  => "  - override/${plugin_name}",
      after => '  - override/module/%{calling_module}',
  }

}


