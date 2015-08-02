case node['platform']
when "debian", "ubuntu"
  include_recipe "apt"
  package "ca-certificates"
end

# Web server
include_recipe 'apache2'

case node['platform']
when "debian", "ubuntu"
  package 'libapache2-mod-passenger'
  apache_module 'passenger'
end

# Database
include_recipe 'postgresql::server'
include_recipe 'database::postgresql'

db_connection_info = {
  :host     => '127.0.0.1',
  :port     => node['postgresql']['config']['port'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database node['participacion']['db']['name'] do
  connection db_connection_info
  action     :create
end

postgresql_database_user node['participacion']['db']['username'] do
  connection db_connection_info
  password node['participacion']['db']['password']
  action :create
end

# App
template "#{node['participacion']['app']['base_dir']}/config/database.yml" do
  source 'database.yml.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
  variables({
  	  :db_name => node['participacion']['db']['name'],
  	  :db_username => node['participacion']['db']['username'],
  	  :db_password => node['participacion']['db']['password']
  	})
end

case node['platform']
when "debian", "ubuntu"
  package 'bundler'
  package 'ruby-execjs' 
end

bash 'Configure and install app' do
  user 'root'
  cwd node['participacion']['app']['base_dir']
  code <<-EOH
    cp config/secrets.yml.example config/secrets.yml
    bundler install
    rake db:migrate
  EOH
end

apache_site "000-default" do
  enable false
  notifies :restart, "service[apache2]"
end

web_app "participacion" do
    template "apache2/participacion.conf.erb"
    docroot "#{node['participacion']['app']['base_dir']}/public"
    notifies :restart, "service[apache2]"
end






