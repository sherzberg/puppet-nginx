class nginx::config {

  Class['nginx::install'] -> Nginx::Vhost <| |>
  Class['nginx::install'] -> Nginx::Upstream <| |>

  Nginx::Vhost <| |>    ~> Exec['nginx_graceful']
  Nginx::Upstream <| |> ~> Exec['nginx_graceful']

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

}
