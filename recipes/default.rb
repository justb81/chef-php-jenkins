include_recipe "jenkins"

include_recipe "ant"
include_recipe "php"

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

php_pear_channel "pear.symfony.com" do
  action :discover
end

php_pear_channel "components.ez.no" do
  action :discover
end

php_pear_channel "pear.phpunit.de" do
  action :discover
end
php_pear_channel "pear.pdepend.org" do
  action :discover
end
php_pear_channel "pear.phpmd.org" do
  action :discover
end

pr = php_pear_channel "pear.phpqatools.org" do
  action :discover
end
pn = php_pear_channel "pear.netpirates.net" do
  action :discover
end

php_pear "phpqatools" do
  channel pr.channel_name
  action :install
end
php_pear "phpDox" do
  preferred_state "alpha"
  channel pn.channel_name
  action :install
end

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
