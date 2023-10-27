# Cookbook Name:: http2k
#
# Provider:: config
#

include Http2k::Helper

action :add do
  begin
    memory = new_resource.memory
    logdir = new_resource.logdir
    user = new_resource.user
    group = new_resource.group
    port = new_resource.port
    domain = new_resource.domain
    kafka_hosts = new_resource.kafka_hosts
    proxy_nodes = new_resource.proxy_nodes
    ipsg_nodes = new_resource.ipsg_nodes
    ips_nodes = new_resource.ips_nodes
    ipscp_nodes = new_resource.ipscp_nodes
    organizations = new_resource.organizations
    locations_list = new_resource.locations_list

    # install package
    dnf_package "redborder-http2k" do
      action :upgrade
      flush_cache [ :before ]
    end

    execute "create_user" do
      command "/usr/sbin/useradd #{user}"
      ignore_failure true
      not_if "getent passwd #{user}"
    end

    directory logdir do
      owner user
      group group
      mode 0770
      action :create
    end

    directory "/etc/http2k" do
      owner user
      group group
      mode 0755
    end

    # Fill organization array
    #organizations = get_organization_uuid

    template "/etc/http2k/config.json" do
      source "http2k_config.json.erb"
      cookbook "http2k"
      owner user
      group group
      mode 0644
      variables(:port => port, :domain => domain, :kafka_hosts => kafka_hosts, :memory => memory,
             :proxy_nodes => proxy_nodes, :ips_nodes => ips_nodes, :ipsg_nodes => ipsg_nodes, :ipscp_nodes => ipscp_nodes,
             :organizations => organizations, :locations_list => locations_list)
      notifies :restart, "service[http2k]", :delayed
    end

    service "http2k" do
      service_name "http2k"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action [:enable,:start]
    end

    Chef::Log.info("http2k cookbook has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :add_http2k_conf_nginx do
  begin
    port = new_resource.port

    service "nginx" do
      service_name "nginx"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action :nothing
    end

    template "/etc/nginx/conf.d/http2k.conf" do
      source "http2k.conf.erb"
      owner "nginx"
      group "nginx"
      mode 0644
      cookbook "http2k"
      variables(:http2k_port => port)
      notifies :restart, "service[nginx]"
    end

    Chef::Log.info("nginx http2k configuration has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :configure_certs do
  begin
    domain = new_resource.domain
    json_cert = nginx_certs("http2k",domain)

    template "/etc/nginx/ssl/http2k.crt" do
      source "cert.crt.erb"
      owner "nginx"
      group "nginx"
      mode 0644
      retries 2
      cookbook "http2k"
      variables(:crt => json_cert["http2k_crt"])
      action :create
      not_if {json_cert.empty?}
    end

    template "/etc/nginx/ssl/http2k.key" do
      source "cert.key.erb"
      owner "nginx"
      group "nginx"
      mode 0644
      retries 2
      cookbook "http2k"
      variables(:key => json_cert["http2k_key"])
      action :create
      not_if {json_cert.empty?}
    end

    Chef::Log.info("Certs for service http2k have been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    logdir = new_resource.logdir

    service "http2k" do
      supports :stop => true
      action :stop
    end

    template_list = [
                      "/etc/http2k/config.json"
                    ]

    dir_list = [
                 "/etc/http2k",
                 logdir
               ]

    # removing templates
    #template_list.each do |temp|
    #  file temp do
    #    action :delete
    #  end
    #end

    # removing directories
    #dir_list.each do |dirs|
    #  directory dirs do
    #    action :delete
    #    recursive true
    #  end
    #end

    # removing package
    #dnf_package 'redborder-http2k' do
    #  action :remove
    #end

    Chef::Log.info("http2k cookbook has been processed")
  rescue => e
    Chef::Log.error(e)
  end
end

action :register do
  begin
    if !node["http2k"]["registered"]
      query = {}
      query["ID"] = "http2k-#{node["hostname"]}"
      query["Name"] = "http2k"
      query["Address"] = "#{node["ipaddress"]}"
      query["Port"] = 7980
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
         command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
         action :nothing
      end.run_action(:run)

      node.normal["http2k"]["registered"] = true
      Chef::Log.info("http2k service has been registered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node["http2k"]["registered"]
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/http2k-#{node["hostname"]} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal["http2k"]["registered"] = false
      Chef::Log.info("http2k service has been deregistered to consul")
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
