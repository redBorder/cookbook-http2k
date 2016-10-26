# Cookbook Name:: http2k
#
# Resource:: config
#

actions :add, :remove
default_action :add

attribute :domain, :kind_of => String, :default => "redborder.cluster"
attribute :memory, :kind_of => Fixnum, :default => 524288
attribute :logdir, :kind_of => String, :default => "/var/log/http2k"
attribute :user, :kind_of => String, :default => "http2k"
attribute :group, :kind_of => String, :default => "http2k"
attribute :port, :kind_of => Fixnum, :default => 7980
attribute :kafka_hosts, :kind_of => Array, :default => "kafka.service"
attribute :proxy_nodes, :kind_of => Object
attribute :ips_nodes, :kind_of => Object
attribute :ipsg_nodes, :kind_of => Object
attribute :organizations, :kind_of => Array
attribute :locations_list, :kind_of => Array
