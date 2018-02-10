class gitify::composer (

) {
  require php

  info 'Installing composer for gitify'

  exec { "composer":
    command => "curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer",
    creates => "/vagrant/composer.phar",
    onlyif  => 'test ! -f /usr/local/bin/composer',
    require => [ Package[ 'curl' ] ],
    before => [ Exec['gitify-get'] ]
  }


  /*
  exec { "mv composer.phar /usr/bin/composer":
    cwd     => "/vagrant",
    creates => "/usr/bin/composer",
    require => Exec ["curl -sS https://getcomposer.org/installer | php"]
  }
  */
}