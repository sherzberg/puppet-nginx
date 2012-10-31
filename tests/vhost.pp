class { 'nginx':
  flavor => 'extras',
}

nginx::vhost { 'example.com':
  ensure       => present,
  listen       => '443',
  ssl          => true,
  ssl_redirect => true,
  ssl_cert     => '/var/www/app/certs/example.com.crt',
  ssl_key      => '/var/www/app/certs/example.com.key',
  aliases      => [ 'sub1.example.com', 'sub2.example.com' ],
  doc_dir      => '/var/www/example.com/current',
  log_dir      => '/var/www/example.com/log',
  proxy_to     => '8080',
  redirect_to  => '/app',
  deny         => [ 'bin', 'conf' ],
}
