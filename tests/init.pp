class { 'nginx':
  flavor => 'extras',
  ssl    => true,
  cert   => 'qa',
}
