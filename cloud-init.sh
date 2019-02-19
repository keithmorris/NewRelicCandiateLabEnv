#cloud-config
groups:
  - ubuntu: [root,sys]
  - cloud-users
users:
  - default
  - name: ${username}
    gecos: New Relic Candidate
    expiredate: ${pw_expiration}
    passwd: ${password}
package_upgrade: true
packages:
  - maven
  - openjdk-8-jdk
  - git
