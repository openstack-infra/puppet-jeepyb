# == Class: jeepyb::fetch_remotes

class jeepyb::fetch_remotes(
  $user    = 'gerrit2',
  $minute  = '*/30',
  $logfile = 'gerritfetchremotes.log',
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
  $logdir = '/var/log/jeepyb'

  include jeepyb

  file { $logdir:
    ensure  => directory,
    owner   => $user,
    require => User[$user],
  }

  cron { 'jeepyb_gerritfetchremotes':
    ensure  => present,
    user    => $user,
    minute  => $minute,
    command => "sleep $((RANDOM\%60+90)) && /usr/local/bin/manage-projects -v >> ${logdir}/${logfile} 2>&1",
    require => File[$logdir],
  }

  include logrotate
  logrotate::file { $logfile:
    ensure  => present,
    log     => "${logdir}/${logfile}",
    options => $log_options,
    require => Cron['jeepyb_gerritfetchremotes'],
  }

  # clean up buggy files
  logrotate::fileremoval {
    '/var/log/jeepyb_gerritfetchremotes.log':
  }
}
