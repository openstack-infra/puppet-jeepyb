# == Class: jeepyb::manage_projects

class jeepyb::manage_projects(
  $timeout = 900, # 15 minutes
  $logdir = '/var/log/jeepyb',
  $logfile = 'manage_projects.log',
  $log_options = [
    'compress',
    'missingok',
    'rotate 30',
    'daily',
    'notifempty',
    'copytruncate',
  ],
) {
  validate_array($log_options)

  include jeepyb

  file { $logdir:
    ensure  => directory,
  }

  exec { 'jeepyb_manage_projects':
    command     => "/usr/local/bin/manage-projects -v >> ${logdir}/${logfile} 2>&1",
    timeout     => $timeout, # 15 minutes
    refreshonly => true,
    logoutput   => true,
    require     => File[$logdir],
  }

  include logrotate
  logrotate::file { $logfile:
    log     => $logfile,
    options => $log_options,
    require => Exec['jeepyb_manage_projects'],
  }
}
