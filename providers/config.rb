# Cookbook Name:: http2k
#
# Provider:: config
#

action :add do
  begin
    memory = new_resource.memory
    logdir = new_resource.logdir
    user = new_resource.user
    group = new_resource.group
    port = new_resource.port
    kafka_hosts = new_resource.kafka_hosts
    http2k_hosts = new_resource.http2k_hosts
    proxy_nodes = new_resource.proxy_nodes
    ipsg_nodes = new_resource.ipsg_nodes
    ips_nodes = new_resource.ips_nodes
    organizations = new_resource.organizations
    locations_list = new_resource.locations_list

#    yum_package "redborder-http2k" do
#      action :upgrade
#      flush_cache [ :before ]
#    end

    user user do
      action :create
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

    template "/etc/http2k/config.json" do
      source "http2k_config.json.erb"
      owner user
      group group
      mode 0644
      variables(
                 :kafka_hosts => kafka_hosts,
                 :http2k_hosts => http2k_hosts,
                 :memory => memory,
                 :proxy_nodes => proxy_nodes,
                 :ips_nodes => ips_nodes,
                 :ipsg_nodes => ipsg_nodes,
                 :organizations => organizations,
                 :locations_list => locations_list
               )
    end

    service "http2k" do
      service_name "http2k"
      supports :status => true, :reload => true, :restart => true, :start => true, :enable => true
      action [:enable,:start]
    end
     
    Chef::Log.info("Http2k has been configurated correctly.")
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
    template_list.each do |temp|
      file temp do
        action :delete
      end
    end
  
    # removing directories
    dir_list.each do |dirs|
      directory dirs do
        action :delete
        recursive true
      end
    end
   
#    yum_package 'redborder-http2k' do
#      action :remove
#    end

    Chef::Log.info("http2k has been deleted correctly.")
  rescue => e
    Chef::Log.error(e.message)
  end
end

