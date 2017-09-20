# == Class: jeepyb
#
class jeepyb (
  $git_source_repo = 'https://git.openstack.org/openstack-infra/jeepyb',
  $git_revision    = 'master',
) {
  case $::osfamily {
    'Debian': {
      $jeepyb_packages = [
        'gcc',
        'libxml2-dev',
        'libxslt1-dev',
        'libffi-dev',
        'libssl-dev'
      ]

      @package { $jeepyb_packages:
        ensure => present,
      }

      realize (
        Package['gcc'],
        Package['libxml2-dev'],
        Package['libxslt1-dev'],
        Package['libffi-dev'],
        Package['libssl-dev'],
      )

      $remove_packages = [
        'python-paramiko',
      ]

      package { $remove_packages:
        ensure => absent,
      }
    }
    'RedHat': {
      $jeepyb_packages = [
        'gcc',
        'libxml2-devel',
        'libxslt-devel',
        'libffi-devel',
        'openssl-devel'
      ]

      @package { $jeepyb_packages:
        ensure => present,
      }

      realize (
        Package['gcc'],
        Package['libxml2-devel'],
        Package['libxslt-devel'],
        Package['libffi-devel'],
        Package['openssl-devel'],
      )

      $remove_packages = [
        'python-paramiko',
        'python-six',
      ]

      package { $remove_packages:
        ensure => absent,
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
    subscribe   => [Vcsrepo['/opt/jeepyb'], Package[$remove_packages]],
    logoutput   => true,
    require     => [Package[$jeepyb_packages], Package[$remove_packages]]
  }
}
