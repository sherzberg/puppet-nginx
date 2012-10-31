# == Class: nginx
#
# Installs and manages Nginx.
#
# === Parameters
#
# [*flavor*]
#  Nginx flavor to install (light, full, extras, passenger). Default: light
#
# === Examples
#
# class { 'nginx':
#   flavor => 'extras',
# }
#
# === Authors
#
# Sergey Stankevich
#
class nginx (
  $flavor = 'light',
) {

  # Compatibility check
  $compatible = [ 'Debian', 'Ubuntu' ]
  if ! ($::operatingsystem in $compatible) {
    fail("Module is not compatible with ${::operatingsystem}")
  }

  $package = $flavor ? {
    'light'     => 'nginx-light',
    'full'      => 'nginx',
    'extras'    => 'nginx-extras',
    'passenger' => 'nginx-passenger',
    default     => 'nginx-light',
  }

  Class['nginx::install'] -> Class['nginx::config']

  include nginx::params
  include nginx::install
  include nginx::config

}
