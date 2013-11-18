class hive::user { 
  
    group {'hive': 
        ensure => present, 
    } 
 
    user {'hive': 
        ensure  => present,
        shell   => '/bin/bash',
        gid     => 'hive',
        require => Group['hive'],
    }

}
