class nginx::install {

  package { $nginx::package: ensure => present }

}
