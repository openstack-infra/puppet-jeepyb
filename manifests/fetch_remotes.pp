# == Class: jeepyb::fetch_remotes

class jeepyb::fetch_remotes(
  $ensure      = present,
  $logfile     = '/var/log/jeepyb_gerritfetchremotes.log',
  $log_options = [
    'compress',
    'missingok',
    'rotate 30',
    'daily',
    'notifempty',
    'copytruncate',
  ],
  $minute      = '*/30',
  $user        = 'gerrit2',
) {
  validate_array($log_options)

  include ::jeepyb

  cron { 'jeepyb_gerritfetchremotes':
    ensure  => $ensure,
    user    => $user,
    minute  => $minute,
    command => "sleep $((RANDOM%60+90)) && /usr/local/bin/manage-projects -v >> ${logfile} 2>&1",
  }

  include ::logrotate
  logrotate::file { $logfile:
    log     => $logfile,
    options => $log_options,
    require => Cron['jeepyb_gerritfetchremotes'],
  }
}
