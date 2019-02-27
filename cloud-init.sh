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
    passwd: ${password}
  - name: tomcat
    system: true
    sudo: ALL=(ALL) NOPASSWD:ALL
package_upgrade: true
packages:
  - maven
  - git
  - mysql-server
runcmd:
  - sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - (cd /tmp && curl -O http://apache.mirrors.tds.net/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz)
  - mkdir /opt/tomcat
  - tar xzvf /tmp/apache-tomcat-9.0.16.tar.gz -C /opt/tomcat --strip-components=1
  - chgrp -R tomcat /opt/tomcat
  - chmod -R g+r /opt/tomcat/conf
  - chmod g+x /opt/tomcat/conf
  - chown -R tomcat /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs
  - iptables -t nat -A OUTPUT -o lo -p tcp --dport 80 -j REDIRECT --to-port 8080
  - git clone https://github.com/nrcandidatelab/ShopizerJavaApp /opt/Shopizer
  - cd /opt/Shopizer
  - reboot
  