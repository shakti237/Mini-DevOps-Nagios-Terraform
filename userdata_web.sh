#!/bin/bash
set -e

# ============================================
# SYSTEM SETUP
# ============================================
apt-get update -y
apt-get install -y nagios-nrpe-server nagios-plugins unzip curl net-tools

# ============================================
# CONFIGURE NRPE
# ============================================
monitoring_ip="172.31.44.22"   # Monitoring Server Private IP

# Allow monitoring server to connect
sed -i "s/^allowed_hosts=.*/allowed_hosts=127.0.0.1,${monitoring_ip}/" /etc/nagios/nrpe.cfg

# Ensure standard NRPE commands exist
cat <<EOF > /etc/nagios/nrpe_local.cfg
# Local NRPE Configuration

command[check_users]=/usr/lib/nagios/plugins/check_users -w 5 -c 10
command[check_load]=/usr/lib/nagios/plugins/check_load -w 5.0,4.0,3.0 -c 10.0,6.0,4.0
command[check_hda1]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /
command[check_total_procs]=/usr/lib/nagios/plugins/check_procs -w 150 -c 250
command[check_zombie_procs]=/usr/lib/nagios/plugins/check_procs -w 5 -c 10 -s Z
EOF

# Include the new NRPE local configuration
if ! grep -q "nrpe_local.cfg" /etc/nagios/nrpe.cfg; then
  echo "include=/etc/nagios/nrpe_local.cfg" >> /etc/nagios/nrpe.cfg
fi

# ============================================
# ENABLE & START NRPE
# ============================================
systemctl enable nagios-nrpe-server
systemctl restart nagios-nrpe-server

# Optional verification logs
echo "NRPE is running and listening on port 5666:"
(netstat -tulnp | grep nrpe || ss -tulnp | grep nrpe) || true

echo "NRPE configuration complete. Allowing monitoring from: ${monitoring_ip}"
