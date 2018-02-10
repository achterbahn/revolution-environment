<?php
/* define the MODX path constants necessary for core installation */
define('MODX_CORE_PATH', dirname(dirname(__FILE__)) . '/core/');
define('MODX_CONFIG_KEY', 'config');

/* define the connection variables */
define('XPDO_DSN', 'mysql:host=localhost;dbname=vagrant;charset=utf8');
define('XPDO_DB_USER', 'vagrant');
define('XPDO_DB_PASS', 'vagrant');
define('XPDO_TABLE_PREFIX', 'modx_');
