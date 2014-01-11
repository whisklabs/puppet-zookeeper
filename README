#puppet-zookeeper

A puppet module for [Apache Zookeeper](http://zookeeper.apache.org/) setup.

## Basic Usage

    node 'zk-1' {
        include java

        class { 'zookeeper':
            myid => '1',
            package_url => 'http://mirrors.ukfast.co.uk/sites/ftp.apache.org/zookeeper/zookeeper-3.4.5/zookeeper-3.4.5.tar.gz'
        }
    }

## Parameters

   - `myid` - cluster-unique zookeeper's instance id (1-255)
   - `package_url` - might use http, ftp, puppet or file scheme
   - `servers` - array of zookeeper servers

