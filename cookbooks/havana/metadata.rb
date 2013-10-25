name             'havana'
maintainer       'baremetalcloud'
maintainer_email 'github@baremetalcloud.com'
license          'Apache 2.0'
description      'Installs/Configures OpenStack Havana'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
%w{partial_search ufw}.each do |cookbook|
	depends cookbook
end
