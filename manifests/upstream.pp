# == Define: nginx::upstream
#
# Manages Nginx upstreams.
#
# === Parameters
#
# [*ensure*]
#  Enable, disable or purge virtual host.
#  present|disabled|absent. Default: present
#
# [*server*]
#  Upstream server.
#
# === Examples
#
# nginx::upstream { 'unicorn':
#   ensure => present,
#   server => 'unix:/var/run/unicorn.socket fail_timeout=0',
# }
#
# === Authors
#
# Sergey Stankevich
#
define nginx::upstream (
  $ensure = present,
  $server = false,
) {

  # Parameter validation
  if ! $server {
    fail('nginx::upstream: server parameter must not be empty')
  }

  $cfg = $title
  $av_cfg = "${nginx::params::av_dir}/${cfg}"
  $en_cfg = "${nginx::params::en_dir}/${cfg}"

  case $ensure {
    present: {
      file { $av_cfg:
        ensure => present,
        mode   => '0644',
        owner  => 'root',
        group  => 'root',
        content => template('nginx/upstream.erb'),
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
        command => "rm ${av_cfg} ${en_cfg}",
        onlyif  => "test -f ${av_cfg} || test -L ${en_cfg}",
      }
    }
  }
}
