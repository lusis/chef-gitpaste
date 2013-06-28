#
# Cookbook Name:: gitpaste
# Recipe:: install
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
include_recipe "git"
include_recipe "python"
include_recipe "openssl"

if node['gitpaste']['secret_key'] == ''
  ::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)
  node.set_unless['gitpaste']['secret_key'] = secure_password()
end

user node['gitpaste']['user'] do
  comment "GitPaste User"
  home node['gitpaste']['homedir']
  shell "/bin/nologin"
  supports :manage_home => true
  action [:create, :modify, :manage]
end

python_virtualenv node['gitpaste']['virtualenv_directory'] do
  interpreter node['gitpaste']['virtualenv_interpreter']
  owner node['gitpaste']['user']
  group node['gitpaste']['group']
  action :create
end

node['gitpaste']['pips'].each do |k,v|
  python_pip k do
    virtualenv node['gitpaste']['virtualenv_directory']
    version v
  end
end

git node['gitpaste']['appdir'] do
  user node['gitpaste']['user']
  group node['gitpaste']['group']
  repository node['gitpaste']['repository']
  reference node['gitpaste']['sha']
  action :sync
end

if node['gitpaste']['google_apps_auth']
  cookbook_file "#{node['gitpaste']['appdir']}/saic/http_remote_user.py" do
    owner node['gitpaste']['user']
    group node['gitpaste']['group']
    mode "0640"
  end
end

template "#{node['gitpaste']['appdir']}/saic/settings.py" do
  cookbook node['gitpaste']['settings_cookbook']
  source node['gitpaste']['settings_template']
  mode "0640"
  owner node['gitpaste']['user']
  group node['gitpaste']['group']
  variables(
    :auth_google => node['gitpaste']['google_apps_auth'],
    :allow_anonymous_posts => node['gitpaste']['allow_anonymous_posts'],
    :allow_anonymous_access => node['gitpaste']['allow_anonymous_access'],
    :admins => node['gitpaste']['admins'],
    :timezone => node['gitpaste']['timezone'],
    :secret_key => node['gitpaste']['secret_key']
  )
end

bash "syncdb" do
  user node['gitpaste']['user']
  group node['gitpaste']['group']
  cwd "#{node['gitpaste']['appdir']}/saic/"
  code <<-EOH
  source #{node['gitpaste']['virtualenv_directory']}/bin/activate
  cd #{node['gitpaste']['appdir']}/saic/
  python manage.py syncdb --noinput
  EOH
  creates "#{node['gitpaste']['appdir']}/saic/paste.db"
end

template "#{node['gitpaste']['virtualenv_directory']}/bin/gitpaste.sh" do
  source "runserver.sh.erb"
  owner node['gitpaste']['user']
  group node['gitpaste']['group']
  mode "0750"
  variables(
    :app_dir => node['gitpaste']['appdir'],
    :venv_dir => node['gitpaste']['virtualenv_directory'],
    :listen_address => node['gitpaste']['gitpaste_address'],
    :listen_port => node['gitpaste']['gitpaste_port']
  )
end

include_recipe "#{node['gitpaste']['svc_cookbook']}::#{node['gitpaste']['svc_type']}"
