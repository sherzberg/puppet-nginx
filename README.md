[puppet-nginx](https://github.com/stankevich/puppet-nginx)
======

Puppet module for installing and managing Nginx, virtual hosts and custom log rotation.

## Usage

### nginx

Installs and manages Nginx.

**flavor** — Nginx flavor to install. light/full/extras/passenger. Default: light

	class { 'nginx':
	  flavor => 'extras',
	}

### nginx::vhost

Manages Nginx virtual hosts.

**ensure** — present/disabled/absent. Default: present

**def_vhost** — Default virtual host. Default: false

**listen** — Port to listen on. Default: 80

**ssl** — Enable SSL. Default: disabled

**ssl_redirect** — Redirect HTTP to HTTPS. Default: disabled

**ssl_cert** — SSL certificate. Default: none

**ssl_key** — SSL key. Default: none

**config** — Name of virtual host template from templates/vhosts. Default: disabled

**aliases** — Server aliases. Default: none

**doc_dir** — Document root. Default: disabled

**log_dir** — Log directory. Default: /var/log/nginx

**proxy_to** — Proxy all requests to a port. Default: disabled

**redirect_to** — Redirect to subdirectory. Default: disabled

**php** — Enable PHP-FPM proxying. Default: disabled

**environment** — Set ENVIRONMENT variable. Default: none

**upstream** — Upstream name. Default: disabled

**deny** — List of "403 Forbidden" locations. Default: disabled

	nginx::vhost { 'example.com':
	  ensure       => present,
	  listen       => '443',
	  ssl          => true,
	  ssl_redirect => true,
	  ssl_cert     => '/var/www/app/certs/example.com.crt',
	  ssl_key      => '/var/www/app/certs/example.com.key',
	  aliases      => [ 'sub1.example.com', 'sub2.example.com' ],
	  doc_dir      => '/var/www/example.com/current',
	  log_dir      => '/var/www/example.com/log',
	  proxy_to     => '8080',
	  redirect_to  => '/app',
	  deny         => [ 'bin', 'conf' ],
	}

### nginx::logrotate

Manages Nginx log rotation.

**ensure** — present/absent. Default: present

**log_dir** — Directory to rotate logs in. Default: /var/log/nginx

	nginx::logrotate { 'example.com':
	  ensure  => present,
	  log_dir => '/var/www/example.com/log',
	}

### nginx::upstream

Manages Nginx upstreams.

**ensure** — present/disabled/absent. Default: present

**server** — Upstream server.

	nginx::upstream { 'unicorn':
	  ensure => present,
	  server => 'unix:/var/run/unicorn.socket fail_timeout=0',
	}

## Authors

[Sergey Stankevich](https://github.com/stankevich)
