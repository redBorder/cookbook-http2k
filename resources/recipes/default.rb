#
# Cookbook Name:: http2k
# Recipe:: default
#
# Copyright 2016, http2k
#
# AFFERO GENERAL PUBLIC LICENSE, Version 3
#

http2k_config "config" do
  action [:add, :register, :configure_certs]
end
