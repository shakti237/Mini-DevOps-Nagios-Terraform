#!/bin/bash
set -e

# ============================================
# SYSTEM SETUP
# ============================================
apt-get update -y
apt-get install -y docker.io nagios-nrpe-server nagios-plugins apache2-utils unzip curl

systemctl enable docker
systemctl start docker

# ============================================
# NAGIOS DOCKER CONTAINER SETUP
# ============================================
docker run -d \
  --name nagios \
  -p 8080:80 \
  -v /opt/nagios/etc:/opt/nagios/etc \
  -v /opt/nagios/var:/opt/nagios/var \
  jasonrivers/nagios

# ============================================
# CONFIGURE NRPE ON MONITORING SERVER
# (for internal checks if needed)
# ============================================
sed -i "s/^allowed_hosts=.*/allowed_hosts=127.0.0.1,172.31.45.34,172.31.0.0\/16/" /etc/nagios/nrpe.cfg
systemctl enable nagios-nrpe-server
systemctl restart nagios-nrpe-server

# ============================================
# CREATE HOST AND SERVICE DEFINITIONS
# ============================================
mkdir -p /opt/nagios/etc/objects

cat > /opt/nagios/etc/objects/client-172-31-45-34.cfg <<EOF
define host {
  use                     linux-server
  host_name               client-172-31-45-34
  alias                   Web Server Instance
  address                 172.31.45.34
}

# NRPE-based service checks
define service {
  use                     generic-service
  host_name               client-172-31-45-34
  service_description     Current Load
  check_command           check_nrpe!check_load
}

define service {
  use                     generic-service
  host_name               client-172-31-45-34
  service_description     Logged-in Users
  check_command           check_nrpe!check_users
}

define service {
  use                     generic-service
  host_name               client-172-31-45-34
  service_description     Root Partition
  check_command           check_nrpe!check_hda1
}

define service {
  use                     generic-service
  host_name               client-172-31-45-34
  service_description     Total Processes
  check_command           check_nrpe!check_total_procs
}

define service {
  use                     generic-service
  host_name               client-172-31-45-34
  service_description     Zombie Processes
  check_command           check_nrpe!check_zombie_procs
}
EOF

# ============================================
# ADD CONFIG TO MAIN NAGIOS FILE (if missing)
# ============================================
if ! grep -q "client-172-31-45-34.cfg" /opt/nagios/etc/nagios.cfg; then
  echo "cfg_file=/opt/nagios/etc/objects/client-172-31-45-34.cfg" >> /opt/nagios/etc/nagios.cfg
fi

# ============================================
# RESTART NAGIOS CONTAINER TO APPLY CONFIG
# ============================================
docker restart nagios
