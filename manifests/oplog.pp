# Enable oplog on the Mongo instance.
class mongodb::oplog(
  $port
) inherits mongodb::params {

  $init_oplog_path = "${boxen::config::home}/bin/init_oplog"
  $homebrew_bindir = "${boxen::config::homebrewdir}/bin"

  file {
    $init_oplog_path:
      mode    => '0755',
      content => template('mongodb/init_oplog.erb') ;
  }
  
  ~>
  exec { "init_oplog":
    # Allow retries to allow some leeway for slow DB boot times.
    command => "${init_oplog_path} ${port}",
    tries => 3,
    try_sleep => 5,
  }
}
