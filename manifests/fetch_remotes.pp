# == Class: jeepyb::fetch_remotes

class jeepyb::fetch_remotes(
  $ensure  = present,
  $user    = 'gerrit2',
  $minute  = '*/30',
  $logfile = '/var/log/jeepyb_gerritfetchremotes.log',
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

  file { '/var/lib/jeepyb':
    ensure => 'directory',
    owner  => $user
  }

  cron { 'jeepyb_gerritfetchremotes':
    ensure      => $ensure,
    user        => $user,
    minute      => $minute,
    command     => "sleep $((RANDOM\%60+90)) && /usr/local/bin/manage-projects -v 2>&1",
    logfile     => $logfile,
  }

  include logrotate
  logrotate::file { $logfile:
    log     => $logfile,
    options => $log_options,
    require => Cron['jeepyb_gerritfetchremotes'],
  }
}
