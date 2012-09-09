class { 'nginx':
  flavor => 'extras',
  ssl    => true,
  cert   => 'qa',
}

nginx::vhost { 'example.com':
  ensure      => present,
  listen      => '443',
  ssl         => true,
  aliases     => [ 'sub1.example.com', 'sub2.example.com' ],
  doc_dir     => '/var/www/example.com/current',
  log_dir     => '/var/www/example.com/log',
  proxy_to    => '8080',
  redirect_to => '/app',
  deny        => [ 'bin', 'conf' ],
}
