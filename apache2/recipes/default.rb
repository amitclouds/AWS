#
# Cookbook Name:: apache2
# Recipe:: default
#
# Copyright 2008, OpsCode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package 'apache2' do
  
  action :install
end

include_recipe 'apache2::service'

service 'apache2' do
    action :enable
end

  
template "#{node[:apache][:dir]}/envvars" do
  source 'envvars.erb'
  owner 'www-data'
  group 'www-data'
  mode 0644
  notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
  only_if { platform?('ubuntu') && node[:platform_version] == '14.04' }
end

template 'apache2.conf' do
  
  path "#{node[:apache][:dir]}/apache2.conf"
  end
  source 'apache2.conf.erb'
  owner 'www-data'
  group 'www-data'
  mode 0644
  notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
end

if platform?('ubuntu') && node[:platform_version] == '14.04'
  execute 'disable config for serve-cgi-bin' do
    command '/usr/sbin/a2disconf serve-cgi-bin'
    user 'root'
  end

  template "#{node[:apache][:dir]}/ports.conf" do
    source "ports.conf.erb"
    owner 'www-data'
    group 'www-data'
    mode 0644
    backup false
  end

  ['security', 'charset'].each do |config|
    template "#{node[:apache][:conf_available_dir]}/#{config}.conf" do
      source "#{config}.conf.erb"
      owner 'www-data'
      group 'www-data'
      mode 0644
      backup false
    end

    execute "enable config #{config}" do
      command "/usr/sbin/a2enconf #{config}"
      root
      notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
    end
  end
else
  template 'security' do
    path "#{node[:apache][:dir]}/conf.d/security"
    source 'security.erb'
    owner 'www-data'
    group 'www-data'
    mode 0644
    backup false
    notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
  end

  template 'charset' do
    path "#{node[:apache][:dir]}/conf.d/charset"
    source 'charset.erb'
    owner 'www-data'
    group 'www-data'
    mode 0644
    backup false
    notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
  end

  template "#{node[:apache][:dir]}/ports.conf" do
    source 'ports.conf.erb'
    group 'www-data'
    owner 'www-data'
    mode 0644
    notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
  end
end

if platform?('ubuntu') && node[:platform_version] == '14.04'
  default_site_config = "#{node[:apache][:dir]}/sites-available/000-default.conf"
else
  default_site_config = "#{node[:apache][:dir]}/sites-available/default"
end
template default_site_config do
  source 'default-site.erb'
  owner 'www-data'
  group 'www-data'
  mode 0644
  notifies :run, resources(:bash => 'logdir_existence_and_restart_apache2')
end

include_recipe 'apache2::mod_status'
include_recipe 'apache2::mod_headers'
#include_recipe 'apache2::mod_alias'
#include_recipe 'apache2::mod_auth_basic'
#include_recipe 'apache2::mod_authn_file'
#include_recipe 'apache2::mod_authz_default' if node[:apache][:version] == '2.2'
#include_recipe 'apache2::mod_authz_groupfile'
#include_recipe 'apache2::mod_authz_host'
#include_recipe 'apache2::mod_authz_user'
#include_recipe 'apache2::mod_autoindex'
#include_recipe 'apache2::mod_dir'
include_recipe 'apache2::mod_env'
#include_recipe 'apache2::mod_mime'
#include_recipe 'apache2::mod_negotiation'
#include_recipe 'apache2::mod_setenvif'
#include_recipe 'apache2::mod_log_config' if platform_family?('rhel')
#include_recipe 'apache2::mod_ssl'
#include_recipe 'apache2::mod_expires'
include_recipe 'apache2::logrotate'

bash 'logdir_existence_and_restart_apache2' do
  action :run
end

file "#{node[:apache][:document_www-data]}/index.html" do
  action :delete
  backup false
  only_if do
    File.exists?("#{node[:apache][:document_www-data]}/index.html")
  end
end
