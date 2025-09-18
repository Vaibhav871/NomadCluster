
#!/bin/bash
set -e
echo "Configuring Nomad Client..."

# Variables for AWS tag-based discovery and datacenter name
SERVER_AWS_TAG_KEY="NomadServer"
SERVER_AWS_TAG_VALUE="true"
DATACENTER_NAME="dc1"    # Change to your preferred datacenter label

# Retrieve instance's private IP (not strictly necessary here)
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Security best practices: Create and lock down directories
sudo mkdir -p /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo mkdir -p /opt/nomad
sudo chmod 700 /opt/nomad
sudo mkdir -p /opt/alloc_mounts
sudo chmod 700 /opt/alloc_mounts

# (Recommended) Use a dedicated nomad system user. Uncomment if needed:
# sudo useradd --system --home /opt/nomad --shell /bin/false nomad
# sudo chown -R nomad:nomad /etc/nomad.d /opt/nomad /opt/alloc_mounts

# Write Nomad client configuration with explicit datacenter and AWS server auto-discovery
sudo tee /etc/nomad.d/client.hcl > /dev/null <<EOF
datacenter = "${DATACENTER_NAME}"
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
# sudo chown nomad:nomad /etc/nomad.d/client.hcl

# Restart and enable Nomad service
sudo systemctl restart nomad
sudo systemctl enable nomad