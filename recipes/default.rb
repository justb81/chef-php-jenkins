include_recipe "jenkins::server"

include_recipe "ant"
include_recipe "php"

package "build-essential" do
  action :install
end

# Install SCM
package "git-core" do
  action :install
end

package "mercurial" do
  action :install
end

# Install PHP modules and PEAR packages
package "php5-xsl" do
  action :install
end

sr = php_pear_channel "pear.symfony-project.com" do
  action :discover
end

s2r = php_pear_channel "pear.symfony.com" do
  action :discover
end

php_pear_channel "components.ez.no" do
  action :discover
end

ur = php_pear_channel "pear.phpunit.de" do
  action :discover
end
#php_pear_channel "pear.pdepend.org" do
#  action :discover
#end
#php_pear_channel "pear.phpmd.org" do
#  action :discover
#end

# Install the latest version of PHPUnit who works with ZF 1

php_pear "Finder" do
  action :install
  preferred_state :beta
  channel s2r.channel_name
end

php_pear "YAML" do
  action :install
  version "1.0.2"
  channel sr.channel_name
end

php_pear "PHPUnit_Selenium" do
  action :install
  version "1.0.1"
  channel ur.channel_name
end

php_pear "Text_Template" do
  action :install
  version "1.0.0"
  channel ur.channel_name
end

php_pear "PHPUnit_MockObject" do
  action :install
  version "1.0.3"
  channel ur.channel_name
end

php_pear "PHP_Timer" do
  action :install
  version "1.0.0"
  channel ur.channel_name
end

php_pear "File_Iterator" do
  action :install
  version "1.2.3"
  channel ur.channel_name
end

php_pear "PHP_TokenStream" do
  action :install
  version "1.0.1"
  channel ur.channel_name
end

php_pear "PHP_CodeCoverage" do
  action :install
  version "1.0.2"
  channel ur.channel_name
end

php_pear "FinderFacade" do
  action :install
  version "1.0.4"
  channel ur.channel_name
end

php_pear "DbUnit" do
  action :install
  version "1.0.0"
  channel ur.channel_name
end

php_pear "PHPUnit" do
  action :install
  version "3.5.15"
  channel ur.channel_name
end

pr = php_pear_channel "pear.phpqatools.org" do
  action :discover
end
pn = php_pear_channel "pear.netpirates.net" do
  action :discover
end

php_pear "phploc" do
  channel ur.channel_name
  action :install
end

#php_pear "phpDox" do
#  preferred_state "alpha"
#  channel pn.channel_name
#  action :install
#end

ENV['JENKINS_URL'] = node['jenkins']['server']['url']  

# workaround for https://github.com/fnichol/chef-jenkins/issues/9
directory "#{node['jenkins']['server']['home']}/updates/" do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  action :create
end

execute "update jenkins update center" do
  command "wget http://updates.jenkins-ci.org/update-center.json -qO- | sed '1d;$d'  > #{node['jenkins']['server']['home']}/updates/default.json"
  user node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  creates "#{node['jenkins']['server']['home']}/updates/default.json"
end

execute "jenkins-cli install-plugin checkstyle cloverphp dry htmlpublisher jdepend plot pmd violations xunit git mercurial"

directory "#{node['jenkins']['server']['home']}/jobs/php-template/" do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  action :create
end

template "#{node['jenkins']['server']['home']}/jobs/php-template/config.xml" do
  source "config.xml.erb"
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['user']
  mode "0644"
end

execute "jenkins-cli safe-restart"
