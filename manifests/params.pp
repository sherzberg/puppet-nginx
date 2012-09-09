class nginx::params {

  $log_dir = '/var/log/nginx'
  $av_dir  = '/etc/nginx/sites-available'
  $en_dir  = '/etc/nginx/sites-enabled'

  ### SSL ###
  $ssl_cert = '/etc/ssl/certs/ssl-cert.pem'
  $ssl_key  = '/etc/ssl/private/ssl-cert.key'

}
