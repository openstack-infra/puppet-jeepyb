# == Class: jeepyb::fetch_remotes

class jeepyb::fetch_remotes(
  $ensure  = present,
  $user    = 'gerrit2',
  $minute  = '*/30',
  $logdir = '/var/log/jeepyb',
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

  include jeepyb

  file { $logdir:
    ensure  => directory,
    owner   => $user,
    require => User[$user],
  }

  cron { 'jeepyb_gerritfetchremotes':
    ensure  => $ensure,
    user    => $user,
    minute  => $minute,
    command => "sleep $((RANDOM\%60+90)) && /usr/local/bin/manage-projects -v >> ${logdir}/${logfile} 2>&1",
    require => File[$logdir],
  }

  if $ensure == 'present' {
    include logrotate
    logrotate::file { "${logdir}/${logfile}":
      log     => "${logdir}/${logfile}",
      options => $log_options,
      require => Cron['jeepyb_gerritfetchremotes'],
    }
  }
  else {
    logrotate::fileremoval { 'jeepyb_removal':
      files => [  '/var/log/jeepyb_gerritfetchremotes.log',
                  "${logdir}/${logfile}" ],
    }
  }
}
