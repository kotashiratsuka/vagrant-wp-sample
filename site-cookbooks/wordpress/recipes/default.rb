#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{httpd php php-mbstring php-xml php-mysql}.each do |p|
  package p do
    action :install
  end
end

%w{httpd}.each do |s|
  service s do
    supports [:restart, :reload, :status]
    action [:enable, :start]
  end
end

script "mysql_create" do
  interpreter "bash"
  user        "root"
  code <<-EOH
    mysql --password=password -e "create database wordpress;"
    mysql --password=password -e "grant all privileges on wordpress.* to wordpress@localhost identified by 'wordpress';"
    mysql --password=password -e "flush privileges;"
    EOH
end

remote_file "/tmp/wordpress.tgz" do
  source "http://ja.wordpress.org/latest-ja.tar.gz"
end

script "install_wordpress" do
  interpreter "bash"
  user        "root"
  code <<-EOH
    install -d /var/www/html
    tar zxvf /tmp/wordpress.tgz -C /var/www/html
    chown -R apache:apache /var/www/html/wordpress
    EOH
end

template "/var/www/html/wordpress/wp-config.php" do
  source "wp-config.php.erb"
end

template "/etc/httpd/conf.d/wordpress.conf" do
  source "wordpress.conf.erb"
  notifies :restart, 'service[httpd]', :immediately
end
