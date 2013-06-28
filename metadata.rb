name             'gitpaste'
maintainer       'John E. Vincent'
maintainer_email 'lusis.org+github.com@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures gitpaste'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.1'

recipe "gitpaste", "Installs gitpaste and runs it under defined service"
recipe "gitpaste::install", "Installs gitpaste"
recipe "gitpaste::runit", "runit_service resource for gitpaste"
recipe "gitpaste::apache", "Apache SSL front-end for gitpaste"

%w{openssl apt apache2 python git runit}.each do |cb|
  depends cb
end

%w{ubuntu debian}.each do |os|
  supports os
end
