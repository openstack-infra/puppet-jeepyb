# == Class: jeepyb
#
class jeepyb (
  $git_source_repo = 'https://git.openstack.org/openstack-infra/jeepyb',
  $git_revision    = 'master',
) {
  if ! defined(Package['python-paramiko']) {
    package { 'python-paramiko':
      ensure   => present,
    }
  }

  if ! defined(Package['gcc']) {
    package { 'gcc':
      ensure => present,
    }
  }

  case $::osfamily {
    'Debian': {
      $pydev   = 'python-dev'
      $openssl = 'libssl-dev'
      $pyyaml  = 'python-yaml'
      $libxml2 = 'libxml2-dev'
      $libxslt = 'libxslt1-dev'
      $libffi  = 'libffi-dev'
    }
    'RedHat': {
      $pydev   = 'python-devel'
      $openssl = 'openssl-devel'
      $pyyaml  = 'PyYAML'
      $libxml2 = 'libxml2-devel'
      $libxslt = 'libxslt-devel'
      $libffi  = 'libffi-devel'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'jeepyb' module only supports osfamily Debian or RedHat.")
    }
  }

  if ! defined(Package[$pydev]) {
    package { "$pydev":
      ensure => present,
    }
  }
  if ! defined(Package[$openssl]) {
    package { "$openssl":
      ensure => present,
    }
  }
  if ! defined(Package[$pyyaml]) {
    package { "$pyyaml":
      ensure => present,
    }
  }
  if ! defined(Package[$libxml2]) {
    package { "$libxml2":
      ensure => present,
    }
  }
  if ! defined(Package[$libxslt]) {
    package { "$libxslt":
      ensure => present,
    }
  }
  if ! defined(Package[$libffi]) {
    package { "$libffi":
      ensure => present,
    }
  }

  vcsrepo { '/opt/jeepyb':
    ensure   => latest,
    provider => git,
    revision => $git_revision,
    source   => $git_source_repo,
  }

  exec { 'install_jeepyb' :
    command     => 'pip install -U /opt/jeepyb',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/jeepyb'],
    logoutput   => true,
    require     => [
                    Class['pip'],
                    Package['gcc'],
                    Package['python-paramiko'],
                    Package[$pydev],
                    Package[$openssl],
                    Package[$pyyaml],
                    Package[$libxml2],
                    Package[$libxslt],
                    Package[$libffi]
                    ]
  }
}
