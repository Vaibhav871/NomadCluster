
#!/bin/bash
set -e
echo "Configuring Nomad Client..."

# Variables for AWS tag-based discovery and datacenter name
SERVER_AWS_TAG_KEY="nomad-server"
SERVER_AWS_TAG_VALUE="true"


# Retrieve instance's private IP (not strictly necessary here)
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Security best practices: Create and lock down directories
sudo mkdir -p /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo mkdir -p /opt/nomad
sudo chmod 700 /opt/nomad
sudo mkdir -p /opt/alloc_mounts
sudo chmod 700 /opt/alloc_mounts


sudo tee /etc/nomad.d/client.hcl > /dev/null <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"

client {
  enabled = true
}

telemetry {
  collection_interval         = "15s"
  prometheus_metrics          = true
  publish_allocation_metrics  = true
  publish_node_metrics        = true
  disable_hostname            = true
}

server_join {
  retry_join     = ["provider=aws tag_key=${SERVER_AWS_TAG_KEY} tag_value=${SERVER_AWS_TAG_VALUE}"]
  retry_interval = "15s"
}
EOF

# Harden permissions on config file
sudo chmod 600 /etc/nomad.d/client.hcl

# (Optional) Set owner to nomad if running agent as non-root.
sudo chown nomad:nomad /etc/nomad.d/client.hcl

# Restart and enable Nomad service
sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl restart nomad
