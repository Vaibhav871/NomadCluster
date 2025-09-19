#!/bin/bash
set -e
echo "Configuring Nomad Client..."


mkdir -p /opt/nomad
mkdir -p /opt/nomad/plugins
chown -R nomad:nomad /opt/nomad
chmod 700 /opt/nomad
chmod 700 /opt/nomad/plugins

mkdir -p /opt/alloc_mounts
chown -R nomad:nomad /opt/alloc_mounts
chmod 700 /opt/alloc_mounts

# Nomad config
cat > /etc/nomad.d/client.hcl <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"

client {
  enabled = true
}

server_join {
  retry_join = ["provider=aws tag_key=Name tag_value=nomad-server"]
  retry_max = 10
  retry_interval = "15s"
}

telemetry {
  collection_interval        = "15s"
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  disable_hostname           = true
}
EOF

chown nomad:nomad /etc/nomad.d/client.hcl
chmod 640 /etc/nomad.d/client.hcl

# Docker permissions
usermod -aG docker nomad


systemctl daemon-reload
systemctl enable docker
systemctl start docker

# Start Nomad
systemctl enable nomad
systemctl start nomad

echo "Nomad client configured via User Data."
