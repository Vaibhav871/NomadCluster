#!/bin/bash
set -e
echo "Configuring Nomad Client..."

# Directories for Nomad
sudo mkdir -p /opt/nomad
sudo chown -R nomad:nomad /opt/nomad
sudo chmod 700 /opt/nomad

sudo mkdir -p /opt/alloc_mounts
sudo chown -R nomad:nomad /opt/alloc_mounts
sudo chmod 700 /opt/alloc_mounts

# Create Nomad client config
sudo bash -c 'cat > /etc/nomad.d/client.hcl <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"

client {
  enabled = true
}

server_join {
  # AWS cloud auto-join using EC2 tags
  retry_join = ["provider=aws tag_key=Name tag_value=nomad-server"]
  retry_max = 10        # Increase retry count for AWS instances startup delays
  retry_interval = "15s" # Reduce interval to retry faster
}

telemetry {
  collection_interval        = "15s"
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
  disable_hostname           = true
}
EOF'

# Set proper ownership
sudo chown nomad:nomad /etc/nomad.d/client.hcl
sudo chmod 640 /etc/nomad.d/client.hcl

# Docker permissions
sudo usermod -aG docker nomad
newgrp docker

# Restart services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart nomad
sudo systemctl enable nomad

echo "Nomad client configured with AWS auto-join."
