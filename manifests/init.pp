# == Class: jeepyb
#
class jeepyb (
  $git_source_repo = 'https://git.openstack.org/openstack-infra/jeepyb',
  $git_revision    = 'master',
) {
  # A lot of things need yaml, be conservative requiring this package to avoid
  # conflicts with other modules.
  case $::osfamily {
    'Debian': {
      $jeepyb_packages = [
        'python-paramiko',
        'gcc',
        'python-yaml',
        'libxml2-dev',
        'libxslt1-dev',
        'libffi-dev',
        'libssl-dev'
      ]
    }
    'RedHat': {
      $jeepyb_packages = [
        'python-paramiko',
        'gcc',
        'PyYAML',
        'libxml2-devel',
        'libxslt-devel',
        'libffi-devel',
        'openssl-devel'
      ]
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

  ensure_packages($jeepyb_packages)

  exec { 'install_jeepyb' :
    command     => 'pip install -U /opt/jeepyb',
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo['/opt/jeepyb'],
    logoutput   => true,
    require     => Package[$jeepyb_packages]
  }
}
