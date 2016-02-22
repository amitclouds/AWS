#
# Cookbook Name:: apache2
# Attributes:: apache
#
# Copyright 2008, OpsCode, Inc.
#
# 
###

case node[:platform_family]

when 'debian'
  default[:apache][:dir]           = '/etc/apache2'
  default[:apache][:log_dir]       = '/var/log/apache2'
  default[:apache][:user]          = 'www-data'
  default[:apache][:group]         = 'www-data'
  default[:apache][:binary]        = '/usr/sbin/apache2'
  default[:apache][:icondir]       = '/usr/share/apache2/icons/'
  default[:apache][:init_script]   = '/etc/init.d/apache2'
  if platform?('ubuntu') && node[:platform_version] == '14.04'
    default[:apache][:version]             = '2.4'
    default[:apache][:conf_available_dir]  = "#{node[:apache][:dir]}/conf-available"
    default[:apache][:conf_enabled_dir]    = "#{node[:apache][:dir]}/conf-enabled"
    default[:apache][:pid_file]            = '/var/run/apache2/apache2.pid'
  else
    default[:apache][:version]             = '2.2'
    default[:apache][:conf_available_dir]  = "#{node[:apache][:dir]}/conf.d"
    default[:apache][:conf_enabled_dir]    = "#{node[:apache][:dir]}/conf.d"
    default[:apache][:pid_file]            = '/var/run/apache2.pid'
  end
  default[:apache][:lock_dir]      = '/var/lock/apache2'
  default[:apache][:lib_dir]       = '/usr/lib/apache2'
  default[:apache][:libexecdir]    = "#{node[:apache][:lib_dir]}/modules"
  default[:apache][:document_root] = '/var/www'
else
  raise "Bailing out, unknown platform '#{node[:platform_family]}'."
end

# General settings
default[:apache][:listen_ports] = [ '80','443' ]
default[:apache][:contact] = 'ops@example.com'
default[:apache][:log_level] = 'info'
default[:apache][:timeout] = 120
default[:apache][:keepalive] = 'Off'
default[:apache][:keepaliverequests] = 100
default[:apache][:keepalivetimeout] = 3
default[:apache][:deflate_types] = ['application/javascript',
                                    'application/json',
                                    'application/x-javascript',
                                    'application/xhtml+xml',
                                    'application/xml',
                                    'text/css',
                                    'text/html',
                                    'text/javascript',
                                    'text/plain',
                                    'text/xml']

# Security
default[:apache][:servertokens] = 'Prod'
default[:apache][:serversignature] = 'Off'
default[:apache][:traceenable] = 'Off'
default[:apache][:hide_info_headers] = true

# Prefork Attributes
default[:apache][:prefork][:startservers] = 16
default[:apache][:prefork][:minspareservers] = 16
default[:apache][:prefork][:maxspareservers] = 32
default[:apache][:prefork][:serverlimit] = 400
default[:apache][:prefork][:maxclients] = 400
default[:apache][:prefork][:maxrequestworkers] = 40
default[:apache][:prefork][:maxrequestsperchild] = 1000
default[:apache][:prefork][:maxconnectionsperchild] = 0

# Worker Attributes
default[:apache][:worker][:startservers] = 2
default[:apache][:worker][:maxclients] = 1024
default[:apache][:worker][:maxrequestworkers] = 1024
default[:apache][:worker][:minsparethreads] = 64
default[:apache][:worker][:maxsparethreads] = 192
default[:apache][:worker][:threadsperchild] = 64
default[:apache][:worker][:maxrequestsperchild] = 10000
default[:apache][:worker][:maxconnectionsperchild] = 10000

# logrotate
default[:apache][:logrotate][:schedule] = 'daily'
default[:apache][:logrotate][:rotate] = '30'
default[:apache][:logrotate][:delaycompress] = true
default[:apache][:logrotate][:mode] = '640'
default[:apache][:logrotate][:owner] = 'root'
default[:apache][:logrotate][:group] = 'adm'

include_attribute 'apache2::customize'
