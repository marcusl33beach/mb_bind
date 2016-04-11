# Cookbook Name:: local_bind
# Recipe:: default

# Install a few tools
package 'bind-utils' do
  action :install
end

# Install bind
package 'bind' do
  action :install
end

# Start up the named service and enable it for restart
service 'named' do
  supports :status => true
  action [ :enable, :start ]
end

# Write out named.conf file
template '/var/named/named.conf' do
  source 'named.conf.erb'
  owner 'named'
  group 'named'
  mode '0655'
  variables({
    :ipaddress => node['ipaddress'],
    :allowquery => node['bind']['allow_query'],
    :forwarders => node['bind']['forwarders'],
    :zone_name => node['bind']['zone_name']
  })
  notifies :reload, 'service[named]'
end

# Write out the marcusbeach.co zone
template "/var/named/#{node['bind']['zone_name']}.zone" do
  source 'zone.zone.erb'
  owner 'named'
  group 'named'
  mode '0655'
  variables({
    :zone_name => node['bind']['zone_name'],
    :serial => node['bind']['serial'],
    :nsrecords => node['bind']['ns_records'],
    :arecords => node['bind']['a_records'],
    :refresh => node['bind']['refresh'],
    :retry => node['bind']['retry'],
    :expire => node['bind']['expire'],
    :ttl => node['bind']['ttl'],
    :minimum => node['bind']['minimum']
  })
  notifies :reload, 'service[named]'
end
