# == Class: jeepyb::manage_projects

class jeepyb::manage_projects(
  $timeout = 900, # 15 minutes
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
  validate_array($log_options)

  include ::jeepyb

  exec { 'jeepyb_manage_projects':
    ensure      => $ensure,
    command     => "/usr/local/bin/manage-projects -v -l ${logdir}/${logfile}",
    timeout     => $timeout, # 15 minutes
    refreshonly => true,
    logoutput   => true,
  }

  include ::logrotate
  logrotate::file { $logfile:
    log     => $logfile,
    options => $log_options,
    require => Exec['jeepyb_manage_projects'],
  }
}
