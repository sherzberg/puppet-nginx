# == Define: nginx::logrotate
#
# Manages Nginx log rotation.
#
# === Parameters
#
# [*ensure*]
#  Present or absent. Default: present
#
# [*log_dir*]
#  Directory to rotate logs in. Default: /var/log/nginx
#
# === Examples
#
# nginx::logrotate { 'example.com':
#   ensure  => present,
#   log_dir => '/var/www/example.com/log',
# }
#
# === Authors
#
# Sergey Stankevich
#
define nginx::logrotate (
  $ensure  = present,
  $log_dir = $nginx::params::log_dir
) {

  case $log_dir {
    $nginx::params::log_dir: {
      file { '/etc/logrotate.d/nginx': ensure => absent }
      $config = 'logrotate.conf'
    }

    default: {
      $config = "logrotate_${name}.conf"
    }
  }

  file { "/etc/nginx/${config}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('nginx/logrotate.conf.erb'),
  }

  cron { "logrotate_${name}":
    ensure  => $ensure,
    command => "/usr/sbin/logrotate -f /etc/nginx/${config}",
    user    => 'root',
    hour    => '0',
    minute  => '0',
  }

}
