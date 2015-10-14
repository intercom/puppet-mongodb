# Enable oplog on the Mongo instance.
class mongodb::oplog(
  $port
) inherits mongodb::params {

  $init_oplog_path = "${boxen::config::home}/bin/init_oplog"

  file {
    $init_oplog_path:
      source => 'puppet:///modules/mongodb/init_oplog' ;
  }
  
  ~>
  exec { "init_oplog":
    # Allow retries to allow some leeway for slow DB boot times.
    command => "${init_oplog_path} ${port}",
    tries => 3,
    try_sleep => 5,
  }
}
