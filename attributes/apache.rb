default['gitpaste']['apache']['use_ssl'] = true
default['gitpaste']['apache']['ssl_cert'] = 'gitpaste.local.crt'
default['gitpaste']['apache']['ssl_key'] = 'gitpaste.local.key'
default['gitpaste']['apache']['vhost'] = 'gitpaste.local'
default['gitpaste']['apache']['aliases'] = [node.ipaddress, '127.0.0.1']
default['gitpaste']['apache']['config'] = 'gitpaste.apache.erb'
default['gitpaste']['apache']['cookie_name'] = 'gitpaste_oid_12345'

# The following are for Google Apps SSO support
default['gitpaste']['apache']['apps_domain_regex'] = '@mydomain\.com$'
default['gitpaste']['apache']['iddb_directory'] = '/var/tmp'
default['gitpaste']['apache']['iddb_file'] = '.auth.db'

# the following cookbook is where we'll look for the apache template
default['gitpaste']['apache']['cookbook'] = 'gitpaste'
# this cookbook is where we'll grab the certs from
default['gitpaste']['apache']['ssl_cookbook'] = 'gitpaste'
