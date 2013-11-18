# == Class hive
#
# Installs Hive packages (needed for Hive Client).
# Use this in conjunction with hive::master to install and set up a
# Hive Server and Hive Metastore.
#
# == Parameters
# $metastore_host                - fqdn of the metastore host
# $zookeeper_hosts               - Array of zookeeper hostname/IP(:port)s.
#                                  Default: undef (zookeeper lock management
#                                  will not be used).
#
# $jdbc_database                 - Metastore JDBC database name.
#                                  Default: 'hive_metastore'
# $jdbc_username                 - Metastore JDBC username.  Default: hive
# $jdbc_password                 - Metastore JDBC password.  Default: hive
# $jdbc_host                     - Metastore JDBC hostname.  Default: localhost
# $jdbc_port                     - Metastore JDBC port.      Default: 3306
# $jdbc_driver                   - Metastore JDBC driver class name.
#                                  Default: org.apache.derby.jdbc.EmbeddedDriver
# $jdbc_protocol                 - Metastore JDBC protocol.  Default: mysql
#
# $exec_parallel_thread_number   - Number of jobs at most can be executed in parallel.
#                                  Set this to 0 to disable parallel execution.
# $optimize_skewjoin             - Enable or disable skew join optimization.
#                                  Default: false
# $skewjoin_key                  - Number of rows where skew join is used.
#                                - Default: 10000
# $skewjoin_mapjoin_map_tasks    - Number of map tasks used in the follow up
#                                  map join jobfor a skew join.   Default: 10000.
# $skewjoin_mapjoin_min_split    - Skew join minimum split size.  Default: 33554432
#
# $stats_enabled                 - Enable or disable temp Hive stats.  Default: false
# $stats_dbclass                 - The default database class that stores
#                                  temporary hive statistics.  Default: jdbc:derby
# $stats_jdbcdriver              - JDBC driver for the database that stores
#                                  temporary hive statistics.
#                                  Default: org.apache.derby.jdbc.EmbeddedDriver
# $stats_dbconnectionstring      - Connection string for the database that stores
#                                  temporary hive statistics.
#                                  Default: jdbc:derby:;databaseName=TempStatsStore;create=true
#
class hive (
    $metastore_host,
    $zookeeper_hosts             = $hive::defaults::zookeeper_hosts,

    $jdbc_database               = $hive::defaults::jdbc_database,
    $jdbc_username               = $hive::defaults::jdbc_username,
    $jdbc_password               = $hive::defaults::jdbc_password,
    $jdbc_host                   = $hive::defaults::jdbc_host,
    $jdbc_port                   = $hive::defaults::jdbc_port,
    $jdbc_driver                 = $hive::defaults::jdbc_driver,
    $jdbc_protocol               = $hive::defaults::jdbc_protocol,

    $exec_parallel_thread_number = $hive::defaults::exec_parallel_thread_number,
    $optimize_skewjoin           = $hive::defaults::optimize_skewjoin,
    $skewjoin_key                = $hive::defaults::skewjoin_key,
    $skewjoin_mapjoin_map_tasks  = $hive::defaults::skewjoin_mapjoin_map_tasks,

    $stats_enabled               = $hive::defaults::stats_enabled,
    $stats_dbclass               = $hive::defaults::stats_dbclass,
    $stats_jdbcdriver            = $hive::defaults::stats_jdbcdriver,
    $stats_dbconnectionstring    = $hive::defaults::stats_dbconnectionstring,

    $hive_site_template          = $hive::defaults::hive_site_template,
    $hive_exec_log4j_template    = $hive::defaults::hive_exec_log4j_template
) inherits hive::defaults
{
    require hive::user
    #package { 'hive':
    #    ensure => 'installed',
    #}
    file {'/usr/lib/hive':
        ensure    => present,
        source    => 'puppet:///modules/hive/hive-0.12.0-bin',
        owner     => 'hive',
        group     => 'hive',
        ignore    => 'conf',
        recurse   => true,
    }

    file {'/etc/hive':
        ensure => directory,
        owner     => 'hive',
        group     => 'hive',
    }

    file {'/var/log/hive':
        ensure => directory,
        owner     => 'hive',
        group     => 'hive',
    }

    file {'/etc/hive/conf':
        ensure    => present,
        source    => 'puppet:///modules/hive/etc/hive/conf',
        owner     => 'hive',
        group     => 'hive',
        recurse   => true,
        require   => File['/etc/hive'],
    }

    file {'/usr/lib/hive/conf':
        ensure  => link,
        target  => '/etc/hive/conf',
        require => [File['/usr/lib/hive'], File['/etc/hive/conf']],
    }

    file {'/usr/bin/hive':
        ensure    => present,
        source    => 'puppet:///modules/hive/usr/bin/hive',
        owner     => 'hive',
        group     => 'hive',
        recurse   => true,
    }



    # Make sure hive-site.xml is not world readable on the
    # metastore host.  On the metastore host, hive-site.xml
    # will contain database connection credentials.
    $hive_site_mode = $metastore_host ? {
        $::fqdn => '0440',
        default => '0444',
    }
    file { '/etc/hive/conf/hive-site.xml':
        content => template($hive_site_template),
        mode    => $hive_site_mode,
        owner   => 'hive',
        group   => 'hive',
        require => File['/etc/hive/conf'],
    }
    file { '/etc/hive/conf/hive-exec-log4j.properties':
        content => template($hive_exec_log4j_template),
    }
}
