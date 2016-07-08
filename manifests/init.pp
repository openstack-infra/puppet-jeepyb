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

  # A lot of things need yaml, be conservative requiring this package to avoid
  # conflicts with other modules.
  case $::osfamily {
    'Debian': {
      if ! defined(Package['python-yaml']) {
        package { 'python-yaml':
          ensure => present,
        }
      }
      if ! defined(Package['libxml2-dev']) {
        package { 'libxml2-dev':
          ensure => present,
        }
      }
      if ! defined(Package['libxslt1-dev']) {
        package { 'libxslt1-dev':
          ensure => present,
        }
      }
      if ! defined(Package['libffi-dev']) {
        package { 'libffi-dev':
          ensure => present,
        }
      }
      if ! defined(Package['libssl-dev']) {
        package { 'libssl-dev':
          ensure => present,
        }
      }
    }
    'RedHat': {
      if ! defined(Package['PyYAML']) {
        package { 'PyYAML':
          ensure => present,
        }
      }
      if ! defined(Package['libxml2-devel']) {
        package { 'libxml2-devel':
          ensure => present,
        }
      }
      if ! defined(Package['libxslt-devel']) {
        package { 'libxslt-devel':
          ensure => present,
        }
      }
      if ! defined(Package['libffi-devel']) {
        package { 'libffi-devel':
          ensure => present,
        }
      }
      if ! defined(Package['openssl-devel']) {
        package { 'openssl-devel':
          ensure => present,
        }
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'jeepyb' module only supports osfamily Debian or RedHat.")
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
  }
}
