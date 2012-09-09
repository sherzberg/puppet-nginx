# == Define: nginx::vhost
#
# Manages Nginx virtual hosts.
#
# === Parameters
#
# [*ensure*]
#  Enable, disable or purge virtual host.
#  present|disabled|absent. Default: present
#
# [*def_vhost*]
#  Default virtual host. Default: false
#
# [*listen*]
#  Port to listen on. Default: 80
#
# [*ssl*]
#  Enable SSL. Also enables HTTP to HTTPS redirection. Default: disabled
#
# [*config*]
#  Name of virtual host template from templates/vhosts. Default: disabled
#
# [*aliases*]
#  Server aliases. Default: none
#
# [*doc_dir*]
#  Document root. Default: disabled
#
# [*log_dir*]
#  Log directory. Default: /var/log/nginx
#
# [*proxy_to*]
#  Proxy all requests to a port. Default: disabled
#
# [*redirect_to*]
#  Redirect to subdirectory. Default: disabled
#
# [*php*]
#  Enable PHP-FPM proxying. Default: disabled
#
# [*environment*]
#  Set ENVIRONMENT variable. Default: none
#
# [*unicorn*]
#  Enable Unicorn, path to socket. Default: disabled
#
# [*gunicorn*]
#  Enable Gunicorn, path to socket. Default: disabled
#
# [*deny*]
#  List of "403 Forbidden" locations. Default: disabled
#
# === Examples
#
# nginx::vhost { 'example.com':
#   ensure      => present,
#   listen      => '443',
#   ssl         => true,
#   aliases     => [ 'sub1.example.com', 'sub2.example.com' ],
#   doc_dir     => '/var/www/example.com/current',
#   log_dir     => '/var/www/example.com/log',
#   proxy_to    => '8080',
#   redirect_to => '/app',
#   deny        => [ 'bin', 'conf' ],
# }
#
# === Authors
#
# Sergey Stankevich
#
define nginx::vhost (
  $ensure      = present,
  $def_vhost   = false,
  $listen      = '80',
  $ssl         = false,
  $config      = false,
  $aliases     = [],
  $doc_dir     = false,
  $log_dir     = $nginx::params::log_dir,
  $proxy_to    = false,
  $redirect_to = false,
  $php         = false,
  $environment = false,
  $unicorn     = false,
  $gunicorn    = false,
  $deny        = false,
) {

  $cfg = $title
  $av_cfg = "${nginx::params::av_dir}/${cfg}"
  $en_cfg = "${nginx::params::en_dir}/${cfg}"

  case $log_dir {
    $nginx::params::log_dir: { }

    default: {
      $log_ensure = $ensure ? {
        present => 'present',
        default => 'absent',
      }

      nginx::logrotate { $title:
        ensure  => $log_ensure,
        log_dir => $log_dir,
      }
    }
  }

  case $ensure {
    present: {
      file { $av_cfg:
        ensure => present,
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
      }

      case $config {
        false: {
          File[$av_cfg] { content => template('nginx/vhost.erb') }
        }

        default: {
          File[$av_cfg] { content => template("nginx/vhosts/${cfg}.erb") }
        }
      }

      exec { "nginx_enable_${cfg}":
        command => "ln -s ${av_cfg} ${en_cfg}",
        creates => $en_cfg,
        require => File[$av_cfg],
      }
    }

    disabled: {
      exec { "nginx_disable_${cfg}":
        command => "rm ${en_cfg}",
        onlyif  => "test -L ${en_cfg}",
      }
    }

    absent: {
      exec { "nginx_purge_${cfg}":
        command => "rm -f ${av_cfg} ${en_cfg} ${log_dir}/${title}.*",
        onlyif  => "test -f ${av_cfg} || test -L ${en_cfg} \
          || test -f ${log_dir}/${title}.access.log",
      }
    }
  }
}
