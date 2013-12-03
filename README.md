Puppet module for Hive 0.12.
===========

```
Most of the code is a direct copy of https://github.com/wikimedia/puppet-cdh4 's Hive configuration, and config files contained in CDH4.4.0 Hive packages.
```

Puppet module to install Hive (0.12)


Unfortunately no Debian packages are available for Hive 0.12.
Therefore I included the entire Hive 0.12 dir in the puppet module.



### Dependencies not made explicit in the module itself:


- Oracle Java 6 installed on all nodes (requirement of Hive).
- Apache HDFS should be installed (The CDH4 versions included in: https://github.com/wikimedia/puppet-cdh4 ).
- Apache Zookeeper (Tested with: https://github.com/stefanvanwouw/puppet-zookeeper-cdh4 ).
- OS should be Ubuntu/Debian for package dependencies.

### Usage:


On the master node:
```puppet

class { '::mysql::server':
    root_password    => 'yourpassword',
}

class { 'hive::master':
    require => [
        Class['::mysql::server'],
        Class['your::class::that::ensures::java::is::installed'], 
        Class['cdh4::hadoop']
    ],
}
```

On the every node, including all workers and the master:
```puppet
class {'hive':
    metastore_host  => $master,
    zookeeper_hosts => $zookeeper_hosts, # 
    jdbc_password   => 'yourpassword',
    require => [
        Class['your::class::that::ensures::java::is::installed'], 
        Class['cdh4::hadoop'],
        Class['zookeeper'],
        Class['zookeeper::server'],
    ]
}
```
