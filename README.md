# Local MODX dev environment

With this repository you can bootup a local dev environment
for MODX (or other web projects) without polluting your system with MAMP or LAMP configurations.

## Preparation
Checkout the repo as a project next to your MODX project. We assume here that the MODX project 
folder is a sibling to this project folder with the name "revolution":

- revolution-environment (this project)
  - Vagrantfile
  - README.md
  - _server
    - ...
  - _backups
    - ...
- revolution (your MODX project folder, e.g. the git checkout)
  - core
    - ...
  - manager
    - ...
  - ...

If your MODX project folder has a different name, it is best to create a symlink named "revolution" which
targets your revolution folder. 

### Networking setup
On your host system, add the following line to your hosts file:
```
192.168.0.42    local.modx.revolution
```
This will enable you to simply access your MODX site via that URL in the browser.

__NOTE:__ the vagrant box will try to use port 80 of your host to be mapped to the virtual 
apache port 80. So if you have already running a webserver like apache on your host system,
startup will fail with an error message because the port is already in use. The best solution
is to shutdown the local apache then.

## Requirements
You will need to install virtualbox and vagrant on your host system. Once you have done this,
open up a terminal and install vagrant plugins with the following commands:

```bash
vagrant plugin install vagrant-triggers
vagrant plugin install vagrant-vbguest
```

## Startup
To start the local dev webserver, simply type `vagrant up` in the root of this project in 
a terminal. On the first startup, vagrant will then start to download a base linux virtualbox
image, and begin to install needed software (Apache, PHP, etc.).
At the end of the installation phase, you will see a message like this on the terminal:

```

-------------------------------------------------------------------
|                                                                  
| MODX BOOTSTRAP v0.1.12
| Release hint: Local revolution dev environment by SEDA.digital
|
| Do not forget to run the transport.core.php and setup after installation!
|
-------------------------------------------------------------------
| Add the following line to the start of the hosts file on your host
| machine (format is the same for MacOS, Windows and Linux):
|
|    192.168.0.42    local.modx.revolution
|------------------------------------------------------------------
| Access your MODX installation with:
|                                                                   
|    http://local.modx.revolution
|    http://localhost:42080
|    http://192.168.0.42:42080    
|    http://local.modx.revolution:42080     
|      
| To access the DB from your host use the following parameters: 
|    Connection Type: TCP/IP (no socket, no SSH needed)
|    Host: 127.0.0.1 
|    Port: 63306
|    User: root
|    Password: (leave empty, important!)
|      
|------------------------------------------------------------------
```

## Access to the machine
During the installation phase, vagrant automatically copies preconfigured files `build.config.php` and 
`build.properties.php` to the MODX _build folder to enable database access to the virtual 
machine. The box is configured with these database setups:
```
dbname=vagrant
dbuser=vagrant
dbpassword=vagrant
```
Which is quite simple :-). The bootup message also gives you information about 
the different ways to access your MODX site. It is also possible to directly get into
the database inside the virtual machine from your host system (e.g. using SQLPro or MySql Gui 
programs). Connection is done via TCP to the localhosts 127-address with a special port number.
You can use the db user root here, with leaving the password empty. 

## Start with MODX development
When you have booted up the vm for the first time, the MODX build and setup needs to be run
From this point on, you can leave this environment folder alone and switch to the MODX project
folder:

- run `php _build/transport.core.php`. This should work if you have PHP installed on your host system - you don't have to 
login to the vm for doing this. 
- after that, go to `http://local.modx.revolution/setup` and run the setup to create the MODX
database inside the server environment. 