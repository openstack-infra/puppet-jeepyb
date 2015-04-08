# == Class: jeepyb::manage_projects

class jeepyb::manage_projects(
  $timeout = 900, # 15 minutes
  $subscribe = [],
  $require = [],
  $logfile = '/var/log/manage_projects.log',
  $log_options = [
    'compress',
    'missingok',
    'rotate 30',
    'daily',
    'notifempty',
    'copytruncate',
  ],
) {
  validate_array($subscribe)
  validate_array($require)
  validate_array($log_options)

  include jeepyb

  exec { 'jeepyb_manage_projects':
    command     => '/usr/local/bin/manage-projects -v >> ${logfile} 2>&1',
    timeout     => $timeout, # 15 minutes
    subscribe   => $subscribe,
    refreshonly => true,
    logoutput   => true,
    require     => $require,
  }

  include logrotate
  logrotate::file { $logfile:
    log     => $logfile,
    options => $log_options
    require => Exec['jeepyb_manage_projects'],
  }
}
