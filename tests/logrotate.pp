class { 'nginx':
  flavor => 'extras',
}

nginx::logrotate { 'example.com':
  ensure   => present,
  log_dir  => '/var/www/example.com/log',
}
