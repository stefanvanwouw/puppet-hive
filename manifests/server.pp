# == Class hive::server
# Configures hive-server2.  Requires that hadoop is included so that
# hadoop-client is available to create hive HDFS directories.
#
# See: http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH4/4.2.0/CDH4-Installation-Guide/cdh4ig_topic_18_5.html
#
class hive::server
{
    # hive::server requires hadoop client and configs are installed.
    Class['cdh4::hadoop'] -> Class['hive::server']
    Class['hive']   -> Class['hive::server']
    Class['hive::metastore']   -> Class['hive::server']

    #package { 'hive-server2':
    #    ensure => 'installed',
    #    alias  => 'hive-server',
    #}

    file {'/etc/init.d/hive-server2':
        ensure => present,
        source => 'puppet:///modules/hive/etc/init.d/hive-server2',
        owner  => 'root',
        group  => 'root',
    }

    # sudo -u hdfs hadoop fs -mkdir /user/hive
    # sudo -u hdfs hadoop fs -chmod 0775 /user/hive
    # sudo -u hdfs hadoop fs -chown hive:hadoop /user/hive
    cdh4::hadoop::directory { '/user/hive':
        owner   => 'hive',
        group   => 'hadoop',
        mode    => '0775',
        require => File['/usr/lib/hive'],
    }
    # sudo -u hdfs hadoop fs -mkdir /user/hive/warehouse
    # sudo -u hdfs hadoop fs -chmod 1777 /user/hive/warehouse
    # sudo -u hdfs hadoop fs -chown hive:hadoop /user/hive/warehouse
    cdh4::hadoop::directory { '/user/hive/warehouse':
        owner   => 'hive',
        group   => 'hadoop',
        mode    => '1777',
        require => Cdh4::Hadoop::Directory['/user/hive'],
    }

    service { 'hive-server2':
        ensure     => 'running',
        require    => File['/etc/init.d/hive-server2'],
        hasrestart => true,
        hasstatus  => true,
    }
}
