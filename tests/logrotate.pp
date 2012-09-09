class { 'nginx':
  flavor => 'extras',
  ssl    => true,
  cert   => 'qa',
}

nginx::logrotate { 'example.com':
  ensure   => present,
  log_dir  => '/var/www/example.com/log',
}
