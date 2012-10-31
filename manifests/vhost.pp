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
#  Enable SSL. Default: disabled
#
# [*ssl_redirect*]
#  Redirect HTTP to HTTPS. Default: disabled
#
# [*ssl_cert*]
#  SSL certificate. Default: none
#
# [*ssl_key*]
#  SSL key. Default: none
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
# [*upstream*]
#  Upstream name. Default: disabled
#
# [*deny*]
#  List of "403 Forbidden" locations. Default: disabled
#
# === Examples
#
# nginx::vhost { 'example.com':
#   ensure       => present,
#   listen       => '443',
#   ssl          => true,
#   ssl_redirect => true,
#   ssl_cert     => '/var/www/app/certs/example.com.crt',
#   ssl_key      => '/var/www/app/certs/example.com.key',
#   aliases      => [ 'sub1.example.com', 'sub2.example.com' ],
#   doc_dir      => '/var/www/example.com/current',
#   log_dir      => '/var/www/example.com/log',
#   proxy_to     => '8080',
#   redirect_to  => '/app',
#   deny         => [ 'bin', 'conf' ],
# }
#
# === Authors
#
# Sergey Stankevich
#
define nginx::vhost (
  $ensure       = present,
  $def_vhost    = false,
  $listen       = '80',
  $ssl          = false,
  $ssl_redirect = false,
  $ssl_cert     = false,
  $ssl_key      = false,
  $config       = false,
  $aliases      = [],
  $doc_dir      = false,
  $log_dir      = $nginx::params::log_dir,
  $proxy_to     = false,
  $redirect_to  = false,
  $php          = false,
  $environment  = false,
  $upstream     = false,
  $deny         = false,
) {

  # Parameter validation
  if $ssl and ! $ssl_cert {
    fail('nginx::vhost: ssl_cert parameter must not be empty')
  }

  if $ssl and ! $ssl_key {
    fail('nginx::vhost: ssl_key parameter must not be empty')
  }

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
