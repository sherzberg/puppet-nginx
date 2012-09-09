[puppet-nginx](https://github.com/stankevich/puppet-nginx)
======

Puppet module for installing and managing Nginx, virtual hosts and custom log rotation.

## Usage

### nginx

Installs and manages Nginx.

**flavor** — Nginx flavor to install. light/full/extras/passenger. Default: light

**ssl** — Enable SSL. Default: disabled

**cert** — SSL certificate to use. Dir from files/ssl/${dir}. Default: wildcard

	class { 'nginx':
	  flavor => 'extras',
	  ssl    => true,
	  cert   => 'qa',
	}

### nginx::vhost

Manages Nginx virtual hosts.

**ensure** — present/disabled/absent. Default: present

**def_vhost** — Default virtual host. Default: false

**listen** — Port to listen on. Default: 80

**ssl** — Enable SSL. Also enables HTTP to HTTPS redirection. Default: disabled

**config** — Name of virtual host template from templates/vhosts. Default: disabled

**aliases** — Server aliases. Default: none

**doc_dir** — Document root. Default: disabled

**log_dir** — Log directory. Default: /var/log/nginx

**proxy_to** — Proxy all requests to a port. Default: disabled

**redirect_to** — Redirect to subdirectory. Default: disabled

**php** — Enable PHP-FPM proxying. Default: disabled

**environment** — Set ENVIRONMENT variable. Default: none

**unicorn** — Enable Unicorn, path to socket. Default: disabled

**gunicorn** — Enable Gunicorn, path to socket. Default: disabled

**deny** — List of "403 Forbidden" locations. Default: disabled

	nginx::vhost { 'example.com':
	  ensure      => present,
	  listen      => '443',
	  ssl         => true,
	  aliases     => [ 'sub1.example.com', 'sub2.example.com' ],
	  doc_dir     => '/var/www/example.com/current',
	  log_dir     => '/var/www/example.com/log',
	  proxy_to    => '8080',
	  redirect_to => '/app',
	  deny        => [ 'bin', 'conf' ],
	}

### nginx::logrotate

Manages Nginx log rotation.

**ensure** — present/absent. Default: present

**log_dir** — Directory to rotate logs in. Default: /var/log/nginx

	nginx::logrotate { 'example.com':
	  ensure  => present,
	  log_dir => '/var/www/example.com/log',
	}

## Authors

[Sergey Stankevich](https://github.com/stankevich)
