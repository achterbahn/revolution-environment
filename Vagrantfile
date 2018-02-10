# -*- mode: ruby -*-
# vi: set ft=ruby :

# PhpStorm: set filetype to perl to enable syntax highlight (quite same as ruby)

# include colors for output like Colors.red("text")
require_relative "_server/bootstrap/colors"

# load project specific configuration
require 'yaml'
#current_dir    = File.dirname(File.expand_path(__FILE__))
config_data    = YAML.load_file("_server/vagrant.config.yaml")
$global = config_data['configuration'][config_data['configuration']['use']]

# define the defaults unless they are not set in global yaml config
$global['vm']['box']     ||= "ubuntu/trusty64"
$global['vm']['memory']  ||= 2048
$global['vm']['cpu']     ||= 2
$global['ports']['web']  ||= 60000
$global['ports']['ssh']  ||= 22000
$global['ports']['mysql']  ||= 63306
$global['ips']['public'] ||= '192.168.60.1'
$global['folders']['modx']['private']['host'] ||= '../revolution/'
$global['folders']['modx']['private']['guest'] ||= '/vagrant/'
$global['folders']['modx']['public']['host'] ||= '../revolution/'
$global['folders']['modx']['public']['guest'] ||= '/vagrant/'
$global['folders']['log']['host'] ||= '_server/log'
$global['folders']['log']['guest'] ||= '/vagrant/_server/log'

if !Vagrant.has_plugin?("vagrant-triggers")
    puts "'vagrant-triggers' plugin is required"
    puts "This can be installed by running:"
    puts
    puts "> vagrant plugin install vagrant-triggers"
    puts
    exit
end

if !Vagrant.has_plugin?("vagrant-vbguest")
    puts
    puts "'vagrant-vbguest' should be used. Install it with"
    puts "> vagrant plugin install vagrant-vbguest"
    puts
end

Vagrant.configure(2) do |config|
    ################################################################################################
    # Locale setting to ensure all shells will run
    ################################################################################################
    ENV['LC_ALL']="en_US.UTF-8"

    config.vm.box = $global['vm']['box']

    ################################################################################################
    # do not check for box updates, this will speed up start
    ################################################################################################
    config.vm.box_check_update = false

    ################################################################################################
    # name the vm. by using define, vagrant sets the hostname
    ################################################################################################
    config.vm.define $global['vm']['name']

    config.vm.hostname = $global['host']['name']

    config.vm.synced_folder "../revolution/",
      "/www/"

    ################################################################################################
    # Client IP in reserved namespace instead of ports
    ################################################################################################
    config.vm.network "private_network", ip: $global['ips']['public']

    ################################################################################################
    # Expose the box to the port in local network
    ################################################################################################
    config.vm.network "forwarded_port", guest: 80, host: $global['ports']['web']

    # Forward to port 80 automatically, if already assigned, choose another one.
    config.vm.network "forwarded_port", guest: 80, host: 80

    # Forward liver-reload port 9091
    config.vm.network "forwarded_port", guest: 9091, host: 9091, auto_correct: true

    # forward vms mysql to this port to enable easy access from the host
    config.vm.network :forwarded_port, guest: 3306, host: $global['ports']['mysql'], auto_correct: true

    ################################################################################################
    # Use a custom ssh port to prevent collisions with other vagrant machines
    ################################################################################################
    config.vm.network :forwarded_port, guest: 22, host: $global['ports']['ssh'], id: 'ssh'

    ################################################################################################
    # Configure the VM "hardware"
    ################################################################################################
    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", $global['vm']['memory']]
        v.customize ["modifyvm", :id, "--cpus", $global['vm']['cpu']]
    end

    ################################################################################################
    # PROVISION
    # everything needed for modx dev is installed here including restoring of a modx database right
    # after the install. This is needed by gitify to successfully build the database. The gitify restore
    # function cannot be used here, because it needs a running modx instance which we do not have at
    # provisioning time.
    ################################################################################################

    # use a bootstrap script to make some initial steps, like downloading additional data
    config.vm.provision "BOOTSTRAP",
            type: "shell",
            preserve_order: true,
            path: "_server/bootstrap.sh",
            args: [$global['folders']['modx']['private']['guest']]

    config.vm.provision "puppet" do |puppet|
       puppet.facter = {
            "fqdn" => $global['host']['name'],
            "docroot" => '/www/',
            "modx_private" => "/www/",
            "modx_public" => "/www/",
            "apache_log" => $global['folders']['log']['guest'],
            "apache_mod" => $global['software']['apache']['additional_mod']
       }
       puppet.manifests_path = "_server/puppet/manifests/"
       puppet.manifest_file = "modx.pp"
       puppet.module_path = "_server/puppet/modules/"
       puppet.options = "" #--logdest /vagrant/_server/log/puppet.log"
    end

    ################################################################################################
    # use a postinstall script to finish installation
    ################################################################################################
    config.vm.provision "POSTINSTALL",
        type: "shell",
        preserve_order: true,
        path: "_server/postinstall.sh",
        args: ['web', $global['host']['name']]

    ################################################################################################
    # this seems to be needed to automatically start the webserver
    ################################################################################################
    config.vm.provision "APACHE_RESTART",
        type: "shell",
        preserve_order: true,
        inline: "service apache2 restart",
        run: "always"

    config.trigger.after [:up,:reload] do
        puts ""
        puts "-------------------------------------------------------------------"
        puts "|                                                                  "
        puts "| MODX BOOTSTRAP v" + $global['version']
        puts "| " + Colors.yellow("Release hint: " + $global['comment'])

        if ($global['warning'] != "")
            puts "|"
            puts "| " + Colors.blink(Colors.bg_red( Colors.white( $global['warning'] )))
        end

        puts "|"
        puts "-------------------------------------------------------------------"
        puts "| Add the following line to the start of the hosts file on your host"
        puts "| machine (format is the same for MacOS, Windows and Linux):"
        puts "|"
        puts "|    " + $global['ips']['public'] + "    " + $global['host']['name']
        puts "|------------------------------------------------------------------"
        puts "| " + Colors.underline("Access your MODX installation with:")
        puts "|                                                                   "
        puts "|    "+Colors.bg_blue(Colors.white("http://#{$global['host']['name']}"))
        puts "|    http://localhost:#{$global['ports']['web']}"
        puts "|    http://#{$global['ips']['public']}:#{$global['ports']['web']}    "
        puts "|    http://#{$global['host']['name']}:#{$global['ports']['web']}     "
        puts "|      "
        puts "| " + Colors.underline("To access the DB from your host use the following parameters: ")
        puts "|    Connection Type: TCP/IP (no socket, no SSH needed)"
        puts "|    Host: 127.0.0.1 "
        puts "|    Port: #{$global['ports']['mysql']}"
        puts "|    User: root"
        puts "|    Password: (leave empty, important!)"
        puts "|      "
        puts "|------------------------------------------------------------------"
        puts ""
    end

    ################################################################################################
    # DESTROY
    # after destroy we can safely delete contents of modx cache and apache log
    ################################################################################################
    config.trigger.after :destroy do
        info 'CLEANUP: cleaning up modx cache folder'
        FileUtils.rm_rf Dir.glob("/www/core/cache/*")

        info 'CLEANUP: cleaning apache log folder'
        FileUtils.rm_rf Dir.glob("_server/log/*")
    end

    # all interactivity needs to be in the Vagrantfile, user input cannot be used in remote scripts!
    def backupConfirm( trigger )
        puts Colors.bg_blue(Colors.black("\n\tDo you want to backup your MODX database now (on '#{trigger}')? [Y,n] \n"))
        confirm = STDIN.gets.chomp
        if ( confirm == "Y" || confirm=="" || confirm=="y")
            run_remote "sudo chmod a+x /vagrant/_server/backup.sh"
            run_remote "sudo /vagrant/_server/backup.sh #{trigger} #{$global['vm']['name']}"
        else
            puts Colors.yellow("\t==> no backup");
        end
    end

    ################################################################################################
    # HALT
    # before destroy we will make a dump of the database
    ################################################################################################
    config.trigger.before :halt do
        backupConfirm("halt")
    end

    ################################################################################################
    # DESTROY
    # before destroy we will make a dump of the database
    ################################################################################################
    config.trigger.before :destroy do
        backupConfirm("destroy")
    end

end