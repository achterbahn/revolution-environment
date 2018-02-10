node default {

  notify { '################# MODX provisioning ################': }
  $doc_root        = '/www/'
  $sys_packages    = ['build-essential', 'curl', 'joe','git','unzip','apachetop','postfix']
  $mysql_host      = 'localhost'
  $mysql_db        = 'vagrant'
  $mysql_user      = 'vagrant'
  $mysql_pass      = 'vagrant'
  $pma_port        = 8000

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  exec { "apt-update":
      command => "/usr/bin/apt-get update"
  }

  notify { 'Installing OS updates...': }
  #include apt
  class { 'apt':
    update => {
      frequency => 'weekly',
    },
  }
  package { ['python-software-properties']:
    ensure  => present,
    require => Exec['apt-update'],
  }
  package { $sys_packages :
    ensure  => "installed",
    require => Exec['apt-update'],
  }

  notify { 'Provisioning apache...': }

  class { 'apache':
    default_vhost => false,
    default_mods => false,
    mpm_module => false,
    sendfile => "Off",
    user => 'vagrant',
    group => 'vagrant'
  }
  class {
    'apache::mod::prefork':
      startservers => 3,
      minspareservers => 2,
      maxspareservers => 5,
      maxclients => 64,
  }
  include apache::mod::php

  apache::mod{ 'rewrite': }
  apache::mod{ 'expires': }
  apache::mod{ 'headers': }
  apache::mod{ 'setenvif': }
  apache::mod{ 'access_compat': }

  # we can load only 1 additional mod for now via the kickstart bootstrap yaml
  # TODO make an array loop here
  if $apache_mod != "" {
    apache::mod{ $apache_mod: }
  }

  apache::vhost{ 'apache':
    servername => $fqdn,
    default_vhost => true,
    port => 80,
    docroot     => '/www/',
    docroot_owner => 'vagrant',
    docroot_group => 'vagrant',
    ssl => false,
    logroot     => $apache_log,
    directories => [{
        path => '/www/',
        allow_override => ['All']
    }],
  }
  apache::vhost{ 'apache_ssl':
    servername => $fqdn,
    default_vhost => false,
    port => 443,
    docroot     => '/www/',
    docroot_owner => 'vagrant',
    docroot_group => 'vagrant',
    ssl => true,
    logroot     => $apache_log,
    directories => [{
        path => '/www/',
        allow_override => ['All']
    }],
  }

  notify { 'Installing PHP...': }
  class { 'php': }

  notify { 'Installing modules ... $php_modules': }
  $php_modules     = ['imagick', 'xdebug', 'curl', 'mysql', 'cli', 'intl', 'mcrypt', 'gd']
  php::module { $php_modules: }
  php::ini { 'php':
    value   => [
      'date.timezone = "Europe/Berlin"',
      'upload_max_filesize = 8M',
      'short_open_tag = 0',
      'log_errors = On',
      'pcre.backtrack_limit = 2500000',
      'max_execution_time = 300',
      'max_input_time = 300',
      'memory_limit = 512M'
    ],
    target  => 'php.ini',
    service => 'apache2'
  }

  notify { 'Installing Mysql...': }
    class { '::mysql::client':
      package_name => 'mysql-client-5.6'
    }
    class { 'mysql::server':
      package_name => 'mysql-server-5.6',
      root_password => 'vagrant',
      remove_default_accounts => true,
      restart => true,
      require       => Exec['apt-update'],
      override_options => {
        'mysqld' => {
          /*'log_error' => '/vagrant/_server/log/mysql.error.log',*/
          'bind_address' => '0.0.0.0',

          'slow_query_log'      => 1,
          'slow_query_log_file' =>  '/vagrant/_server/log/mysql.slowquery.log',
          'long_query_time'     => 3,

          'log_queries_not_using_indexes' => 1,

          'skip_name_resolve'   => 1,

          'max_connections'     => 16,
          'read_buffer_size'    =>   '8M',  /* allocated per connection */
          'join_buffer_size'    =>   '8M',  /* allocated per connection */
          'sort_buffer_size'    =>   '2M',  /* allocated per connection */
          'key_buffer_size'     => '256M',
          'max_allowed_packet'  =>  '64M',
          'query_cache_limit'   => '512K',
          'query_cache_size'    =>  '64M',
          'thread_cache_size'   =>   64,
          'thread_stack'        =>  '16M',
          'join_buffer_size'    =>  '16M',
          'thread_concurrency'  =>  8
        },
        'mysqldump' => {
          'max_allowed_packet'  => '128M'
        }
      },
  }

  mysql::db { $mysql_db:
    user     => $mysql_user,
    password => $mysql_pass,
    host     => $mysql_host,
    grant    => ['ALL'],
    /* sql      => '/vagrant/_backups/bootstrap.sql' */
  }

  /* allow the root user to access from host */
  /* grant all privileges on *.* to 'root'@'10.0.2.2' with grant option; flush privileges; */
  mysql_grant { 'root@10.0.2.2/*.*':
    ensure     => 'present',
    privileges => ['ALL'],
    options    => ['GRANT'],
    table      => '*.*',
    user       => 'root@10.0.2.2',
  }
  mysql_grant { 'vagrant@10.0.2.2/vagrant.*':
    ensure     => 'present',
    privileges => ['ALL'],
    options    => ['GRANT'],
    table      => 'vagrant.*',
    user       => 'vagrant@10.0.2.2',
  }

  /* prepare gitify package */
  class { 'gitify':
    require => [ Class['php'], Package['git'], Package['unzip'], Package['curl'] ]
  }

  exec { 'gitify-extract-executable':
    command => 'sudo chmod a+x /vagrant/extract.sh',
    onlyif => 'test -f /vagrant/extract.sh',
    require => Exec['gitify-system-install'],
  }

}

/*
    exec {'create_self_signed_sslcert':
      command => "openssl req -newkey rsa:2048 -nodes -keyout ${::fqdn}.key  -x509 -days 365 -out ${::fqdn}.crt -subj '/CN=${::fqdn}'"
      cwd     => $certdir,
      creates => [ "${certdir}/${::fqdn}.key", "${certdir}/${::fqdn}.crt", ],
      path    => ["/usr/bin", "/usr/sbin"]
    }

*/
