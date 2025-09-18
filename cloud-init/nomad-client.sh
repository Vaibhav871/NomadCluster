
#!/bin/bash
set -e
echo "Configuring Nomad Client..."

# Variables for AWS tag-based discovery and datacenter name
# SERVER_AWS_TAG_KEY="nomad-server"
# SERVER_AWS_TAG_VALUE="true"

NOMAD_SERVER_IP="${NOMAD_SERVER_IP}"
INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)



sudo tee /etc/nomad.d/client.hcl > /dev/null <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
bind_addr = "0.0.0.0"


client {
  enabled = true
  servers = ["${NOMAD_SERVER_IP}"]
}

advertise {
  http = "${INSTANCE_IP}"
  rpc  = "${INSTANCE_IP}"
  serf = "${INSTANCE_IP}"
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

sudo mkdir -p /opt/nomad
sudo chown -R nomad:nomad /opt/nomad
sudo chmod 700 /opt/nomad


# Set proper ownership
chown nomad:nomad /etc/nomad.d/client.hcl
systemctl restart nomad
systemctl enable nomad