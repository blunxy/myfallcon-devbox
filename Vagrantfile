# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.box = "myfallcon-devbox"
  config.vm.synced_folder "/home/jpratt/.ssh", "/home/vagrant/.ssh"
  config.vm.hostname = "myfallcon-devbox.com"
  config.vm.network "forwarded_port", guest: 3000, host: 3001

  config.vm.provision "shell", inline: update_repos
  config.vm.provision "shell", inline: install_add_apt_repository

  #nokogiri
  config.vm.provision "shell", inline: install_dependencies(["libxslt-dev", "libxml2-dev"])

  #capybara
  config.vm.provision "shell", inline: install_dependencies(["libqt4-dev"])

  #rmagick
  config.vm.provision "shell", inline: install_dependencies(["libmagickwand-dev"])

  config.vm.provision "shell", inline: install_openssh_server
  config.vm.provision "shell", inline: install_keychain
  config.vm.provision "shell", inline: install_nginx
  config.vm.provision "shell", inline: install_git
  config.vm.provision "shell", inline: install_tree
  config.vm.provision "shell", inline: install_curl
  config.vm.provision "shell", inline: install_tmux
  config.vm.provision "shell", inline: install_nodejs
  config.vm.provision "shell", inline: install_emacs
  config.vm.provision "shell", inline: install_postgresql
  config.vm.provision "shell", inline: install_the_silver_searcher

  config.vm.provision "shell", inline: install_rvm, privileged: false
  config.vm.provision "shell", inline: install_ruby("2.1.1"), privileged: false
  config.vm.provision "shell", inline: turn_off_gemdoc_install, privileged: false
  config.vm.provision "shell", inline: gem_install("bundler"), privileged: false
  config.vm.provision "shell", inline: gem_install("capistrano"), privileged: false
  config.vm.provision "shell", inline: update_gems, privileged: false

  config.vm.provision "shell", inline: setup_postgres_account

  config.vm.provision "shell", inline: tweak_keychain, privileged: false
end

def get_hostname
  hostname = ENV['host'] || "app.example.com"
  "#{hostname}.example.com" if hostname.split("\.").count == 1
end

def get_http_port
  ENV['http_port'] || 3001
end

def update_repos
  "apt-get update"
end

def tweak_keychain
  "echo 'eval \`keychain --eval --agents ssh aki-basement\`' | sudo -u vagrant tee -a ~/.bash_profile"
end

def install_openssh_server
  "#{install("openssh-server")} && sudo service ssh restart"

end

def install_keychain
  "#{install("keychain")} && sudo service ssh restart"
end


def install_nginx
  "#{add_ppa("nginx/stable")} && #{install("nginx")}"
end

def install_emacs
  "#{add_ppa("cassou/emacs")} && #{install("emacs24-nox")}"
end

def setup_postgres_account
  copy_script = "sudo -u postgres cp /vagrant/create_postgresql_account.sh /var/lib/postgresql/init.sh"
  run_script = "sudo su -c /var/lib/postgresql/init.sh postgres"
  "#{copy_script} && #{run_script}"
end

def install_add_apt_repository
  install_dependencies(["python-software-properties", "python", "g++", "make"])
end

def add_ppa(ppa)
  "add-apt-repository -y  ppa:#{ppa} && apt-get update"
end

def install_postgresql
  add_deps = install_dependencies(["libpq-dev"])
  make_list =  "sudo touch /etc/apt/sources.list.d/pgdg.list"
  add_to_list = "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' | sudo tee -a /etc/apt/sources.list.d/pgdg.list"
  add_repo_key = "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - sudo apt-get update && sudo apt-get update"
  set_locale =  "sudo /usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8"
  install = install("postgresql-9.3")
  create_default_store = "sudo mkdir -p /usr/local/pgsql/data && sudo chown postgres:postgres /usr/local/pgsql/data"
  start_it_up = "sudo /etc/init.d/postgresql start"

  "#{add_deps} && #{make_list} && #{add_to_list} && #{add_repo_key} && #{set_locale} && #{install} && #{create_default_store} && #{start_it_up}"
end

def install_nodejs
  "#{add_ppa("chris-lea/node.js")} && #{install("nodejs")}"
end

def turn_off_gemdoc_install
  "echo \"gem: --no-document\" >> ~/.gemrc"
end

def install_rvm
  "\\curl -sSL https://get.rvm.io | bash -s stable" # && source /home/vagrant/.rvm/scripts/rvm"
end

def install_ruby(ver)
  "source /home/vagrant/.rvm/scripts/rvm && /home/vagrant/.rvm/bin/rvm install #{ver} && rvm --default use #{ver}"
end

def install_the_silver_searcher
  "dpkg -i /vagrant/the-silver-searcher_0.14-1_amd64.deb"
end

def git_clone(url, repo_name=nil)
  "git clone #{url} #{repo_name}"
end

def install(pkg)
  "apt-get install -y #{pkg}"
end

def gem_install(gem, ruby_version="2.1.1")
  "source /home/vagrant/.rvm/scripts/rvm && /home/vagrant/.rvm/rubies/ruby-#{ruby_version}/bin/gem install #{gem} --no-ri --no-rdoc"
end

def update_gems
  "source /home/vagrant/.rvm/scripts/rvm &&rvm gemset use global && gem update"
end

def install_dependencies(deps)
  deps.collect {|dep| install(dep)}.join("\n")
end

def method_missing(method_name, *args)
  super unless method_name =~ /install_/
  install(method_name.to_s.split("_")[1])
end
