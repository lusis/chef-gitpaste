#
# Cookbook Name:: gitpaste
# Recipe:: apache
#
# Copyright 2013, John E. Vincent <lusis.org+github.com@gmail.com>
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
include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_auth_openid"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

group node['apache']['group'] do
  members node['gitpaste']['user']
  append true
end

cookbook_file "/etc/apache2/ssl/#{node['gitpaste']['apache']['ssl_cert']}" do
  owner "root"
  group node['apache']['group']
  mode "0440"
  cookbook node['gitpaste']['apache']['ssl_cookbook']
end

cookbook_file "/etc/apache2/ssl/#{node['gitpaste']['apache']['ssl_key']}" do
  owner "root"
  group node['apache']['group']
  mode "0440"
  cookbook node['gitpaste']['apache']['ssl_cookbook']
end

template "/etc/apache2/sites-available/gitpaste" do
  owner node['apache']['user']
  group node['apache']['group']
  variables(
    :server_name => node['gitpaste']['apache']['vhost'],
    :aliases => node['gitpaste']['apache']['aliases'],
    :gitpaste_port => node['gitpaste']['gitpaste_port'],
    :gitpaste_address => node['gitpaste']['gitpaste_address'],
    :auth_google => node['gitpaste']['google_apps_auth'],
    :email_regex => node['gitpaste']['apache']['apps_domain_regex'],
    :db_directory => node['gitpaste']['apache']['iddb_directory'],
    :db_file => node['gitpaste']['apache']['iddb_file'],
    :ssl_cert => node['gitpaste']['apache']['ssl_cert'],
    :ssl_key => node['gitpaste']['apache']['ssl_key'],
    :docroot => "#{node['gitpaste']['appdir']}/saic/paste/static",
    :cookie_name => node['gitpaste']['apache']['cookie_name']
  )
  source node['gitpaste']['apache']['config']
  cookbook node['gitpaste']['apache']['cookbook']
end

apache_site "gitpaste"
