# == Class: jeepyb::openstackwatch

class jeepyb::openstackwatch(
  $swift_auth_url,
  $swift_password,
  $swift_username,
  $json_url,
  $auth_version = '1.0',
  $container    = 'rss',
  $hour         = '*',
  $minute       = '18',
  $mode         = 'multiple',
  $projects     = [],
) {
  include ::jeepyb

  group { 'openstackwatch':
    ensure => present,
  }

  user { 'openstackwatch':
    ensure     => present,
    managehome => true,
    comment    => 'OpenStackWatch User',
    shell      => '/bin/bash',
    gid        => 'openstackwatch',
    require    => Group['openstackwatch'],
  }

  if $swift_password != '' {
    cron { 'openstackwatch':
      ensure  => present,
      command => '/usr/local/bin/openstackwatch /home/openstackwatch/openstackwatch.ini',
      minute  => $minute,
      hour    => $hour,
      user    => 'openstackwatch',
      require => [
        File['/home/openstackwatch/openstackwatch.ini'],
        User['openstackwatch'],
        Class['jeepyb'],
      ],
    }
  }

  file { '/home/openstackwatch/openstackwatch.ini':
    ensure  => present,
    content => template('jeepyb/openstackwatch.ini.erb'),
    owner   => 'root',
    group   => 'openstackwatch',
    mode    => '0640',
    require => User['openstackwatch'],
  }

  if ! defined(Package['python-pyrss2gen']) {
    package { 'python-pyrss2gen':
      ensure => present,
    }
  }

  if ! defined(Package['python-swiftclient']) {
    package { 'python-swiftclient':
      ensure   => latest,
      provider => pip,
      require  => Class['pip'],
    }
  }
}
