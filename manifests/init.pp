# == Class: nginx
#
# Installs and manages Nginx.
#
# === Notes
#
# Module uses Dotdeb (http://www.dotdeb.org/instructions/) Nginx packages.
#
# === Parameters
#
# [*flavor*]
#  Nginx flavor to install (light, full, extras, passenger). Default: light
#
# [*ssl*]
#  Enable SSL. Default: disabled
#
# [*cert*]
#  SSL certificate to use. Dir from files/ssl/${dir}. Default: wildcard
#
# === Examples
#
# class { 'nginx':
#   flavor => 'extras',
#   ssl    => true,
#   cert   => 'qa',
# }
#
# === Authors
#
# Sergey Stankevich
#
class nginx (
  $flavor = 'light',
  $ssl    = false,
  $cert   = 'wildcard'
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
