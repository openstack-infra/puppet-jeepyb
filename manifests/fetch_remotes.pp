# == Class: jeepyb::fetch_remotes

class jeepyb::fetch_remotes(
  $ensure  = present,
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

  include ::jeepyb

  if !defined(File[$logdir]) {
    file { $logdir:
      ensure  => directory,
      owner   => $user,
      mode    => '0755',
      require => User[$user],
    }
  }

  cron { 'jeepyb_gerritfetchremotes':
    ensure  => $ensure,
    user    => $user,
    minute  => $minute,
    command => "sleep $((RANDOM\%60+90)) && /usr/local/bin/manage-projects -v -l ${logdir}/${logfile}",
    require => File[$logdir],
  }

  include ::logrotate
  logrotate::file { $logfile:
    ensure  => $ensure,
    log     => "${logdir}/${logfile}",
    options => $log_options,
    require => Cron['jeepyb_gerritfetchremotes'],
  }

  # clean up buggy files
  logrotate::fileremoval {
    '/var/log/jeepyb_gerritfetchremotes.log':
  }
}
