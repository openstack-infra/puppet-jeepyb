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
  $ensure       = present,
) {
  include ::jeepyb

  group { 'openstackwatch':
    ensure => $ensure,
  }

  user { 'openstackwatch':
    ensure     => $ensure,
    managehome => true,
    comment    => 'OpenStackWatch User',
    shell      => '/bin/bash',
    gid        => 'openstackwatch',
    require    => Group['openstackwatch'],
  }

  if $swift_password != '' {
    cron { 'openstackwatch':
      ensure  => $ensure,
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
    ensure  => $ensure,
    content => template('jeepyb/openstackwatch.ini.erb'),
    owner   => 'root',
    group   => 'openstackwatch',
    mode    => '0640',
    require => User['openstackwatch'],
  }

  if ! defined(Package['python-pyrss2gen']) {
    package { 'python-pyrss2gen':
      ensure => $ensure,
    }
  }

  if ($ensure == present) {
    $latest = latest
  } else {
    $latest = absent
  }

  if ! defined(Package['python-swiftclient']) {
    package { 'python-swiftclient':
      ensure   => $latest,
      provider => openstack_pip,
      require  => Class['pip'],
    }
  }
}
