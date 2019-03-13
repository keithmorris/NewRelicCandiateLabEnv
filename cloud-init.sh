#cloud-config
groups:
  - ubuntu: [root,sys]
  - cloud-users
users:
  - default
  - name: ${username}
    gecos: New Relic Candidate
    sudo: ALL=(ALL) NOPASSWD:ALL
    expiredate: ${pw_expiration}
    ssh_authorized_keys:
      - ${ssh_key}
  - name: tomcat
    sudo: ALL=(ALL) NOPASSWD:ALL
package_upgrade: true
packages:
  - maven
  - git
  - mysql-server
  - iptables-persistent
  - netfilter-persistent
  - openjdk-8-jdk
runcmd:
  - touch /etc/profile.d/00-java.sh
  - echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' | tee -a '/etc/profile.d/00-java.sh'
  - echo 'export JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64' | tee -a '/etc/profile.d/00-java.sh'
  - echo 'export PATH=$JAVA_HOME/bin:$PATH' | tee -a '/etc/profile.d/00-java.sh'
  - touch /etc/sudoers.d/00-java-home
  - echo 'Defaults env_keep += "JAVA_HOME JRE_HOME PATH"' | EDITOR='tee -a' visudo -f /etc/sudoers.d/00-java-home
  - (cd /tmp && curl -O http://apache.mirrors.tds.net/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz)
  - mkdir /opt/tomcat
  - tar xzvf /tmp/apache-tomcat-9.0.16.tar.gz -C /opt/tomcat --strip-components=1
  - chgrp -R tomcat /opt/tomcat
  - chmod -R g+r /opt/tomcat/conf
  - chmod g+x /opt/tomcat/conf
  - chown -R tomcat:tomcat /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs
  - rm -rf /opt/tomcat/webapps/ROOT
  - iptables -t nat -A OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8080
  - netfilter-persistent save
  - git clone https://github.com/nrcandidatelab/ShopizerJavaApp /opt/Shopizer
  - curl -o /tmp/create.sql ${create}
  - mysql < /tmp/create.sql
  - curl -o /tmp/SALESMANAGER.sql ${salesmanager}
  - mysql SALESMANAGER < /tmp/SALESMANAGER.sql
  - (cd /opt/Shopizer && JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 mvn clean install)
  - cp /opt/Shopizer/sm-shop/target/ROOT.war /opt/tomcat/webapps/
  - chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war
