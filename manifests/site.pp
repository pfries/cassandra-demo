
$java_installer   = "jdk-7u51-linux-x64.rpm"
$dependencies_dir = "/vagrant/dependencies"
$java_url         = "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.rpm"
$cassandra_url    = "http://archive.apache.org/dist/cassandra/2.0.6/apache-cassandra-2.0.6-bin.tar.gz"
$cassandra_tar    = "apache-cassandra-2.0.6-bin.tar.gz"


# set global executable search path
Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

package { "wget":
      ensure => present
}
package { "python":
        ensure => present
}
# Downloading JDK...
exec { 'jdk-download':
        command => "wget --no-check-certificate --no-cookies - --header 'Cookie: oraclelicense=accept-securebackup-cookie' ${java_url} -O ${java_installer}",
        creates => "${dependencies_dir}/${java_installer}",
        require => Package["wget"],
        cwd => $dependencies_dir,
}

# Installing JDK

exec { "Install Java":
        command => "sudo rpm -Uvv ${dependencies_dir}/${java_installer}",
        unless  => "rpm -q jdk.x86_64",
        timeout => 0,
        require => Exec["jdk-download"],
        logoutput => "on_failure",
}   

exec { "cassandra-download":
        command => "wget ${cassandra_url} -O ${cassandra_tar}",
        creates => "${dependencies_dir}/${cassandra_tar}",
        require => Package["wget"],
        cwd => $dependencies_dir
}
file{ "/opt/cassandra":
        ensure => "directory",
        owner  => "vagrant",
        group  => "vagrant",
        mode   => 644,
}

exec { "unpack cassandra":
        command => "tar xzvf ${cassandra_tar} -C /home/vagrant/cassandra/",
        cwd => $dependencies_dir,
        require => File["/opt/cassandra"]
}
