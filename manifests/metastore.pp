# == Class hive::metastore
#
class hive::metastore
{
    Class['hive'] -> Class['hive::metastore']

    #package { 'hive-metastore':
    #    ensure => 'installed',
    #}

    file {'/etc/init.d/hive-metastore':
        ensure => present,
        source => 'puppet:///modules/hive/etc/init.d/hive-metastore',
        owner  => 'root',
        group  => 'root',
    }

    service { 'hive-metastore':
        ensure     => 'running',
        require    => File['/etc/init.d/hive-metastore'],
        hasrestart => true,
        hasstatus  => true,
    }
}
