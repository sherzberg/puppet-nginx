class nginx::config {

  Class['nginx::install'] -> Nginx::Vhost <| |>

  Nginx::Vhost <| |> ~> Exec['nginx_graceful']

  service { 'nginx':
    ensure     => running,
    enable     => true,
    hasrestart => true,
  }

  exec { 'nginx_graceful':
    command     => 'invoke-rc.d nginx reload',
    onlyif      => 'invoke-rc.d nginx configtest',
    refreshonly => true,
  }

  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nginx/nginx.conf.erb'),
    notify  => Exec['nginx_graceful'],
  }

  file { '/etc/nginx/conf.d/status.conf':
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nginx/status.conf.erb'),
    notify  => Exec['nginx_graceful'],
  }

  file { '/var/www':
    ensure  => directory,
    mode    => '0755',
    owner   => 'www-data',
    group   => 'www-data',
  }

  # Disabling default virtual host
  nginx::vhost { 'default':
    ensure => disabled,
  }

  # Proper log rotation (at 00:00 daily)
  nginx::logrotate { 'nginx':
    ensure => present,
  }

  # Wildcard SSL certificate files
  $ssl_ensure = $nginx::ssl ? {
    /(true|present)/ => 'present',
    default          => 'absent',
  }

  file { $nginx::params::ssl_cert:
    ensure  => $ssl_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    source  => "puppet:///files/ssl/${nginx::cert}/ssl-cert.pem",
    notify  => Exec['nginx_graceful'],
  }

  file { $nginx::params::ssl_key:
    ensure  => $ssl_ensure,
    mode    => '0640',
    owner   => 'root',
    group   => 'ssl-cert',
    source  => "puppet:///files/ssl/${nginx::cert}/ssl-cert.key",
    notify  => Exec['nginx_graceful'],
  }

}
