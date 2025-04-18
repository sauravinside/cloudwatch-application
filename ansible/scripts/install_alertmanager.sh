#!/bin/bash

# Download Alertmanager binary
wget https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.linux-386.tar.gz

# Create Alertmanager user and group (if they don't exist)
sudo groupadd -f alertmanager || true
sudo useradd -g alertmanager --no-create-home --shell /bin/false alertmanager || true

# Create Alertmanager directories
sudo mkdir -p /etc/alertmanager/templates /var/lib/alertmanager

# Set ownership of Alertmanager directories
sudo chown alertmanager:alertmanager /etc/alertmanager /var/lib/alertmanager

# Extract Alertmanager archive
tar -xvf alertmanager-0.27.0.linux-386.tar.gz

# Move extracted directory
mv alertmanager-0.27.0.linux-386 alertmanager-files

# Copy Alertmanager binary and tool to system binaries directory
sudo cp alertmanager-files/alertmanager /usr/bin/
sudo cp alertmanager-files/amtool /usr/bin/

# Set ownership of Alertmanager binary and tool
sudo chown alertmanager:alertmanager /usr/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/bin/amtool

# Copy Alertmanager configuration file
sudo cp alertmanager-files/alertmanager.yml /etc/alertmanager/alertmanager.yml

# Set ownership of Alertmanager configuration file
sudo chown alertmanager:alertmanager /etc/alertmanager/alertmanager.yml

# Clean up downloaded archive
rm alertmanager-0.27.0.linux-386.tar.gz

# Remove temporary directory (optional)
# rm -rf alertmanager-files

# Create Systemd service file
cat <<EOF > /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/bin/alertmanager \
    --config.file /etc/alertmanager/alertmanager.yml \
    --storage.path /var/lib/alertmanager/
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable/start Alertmanager service
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# Check Alertmanager service status
sudo systemctl status alertmanager

echo "Alertmanager installation and service setup complete!"

# #!/bin/bash
# # scripts/install_alertmanager.sh

# # Download Alertmanager
# cd /tmp
# wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
# tar xvfz alertmanager-*.tar.gz
# cd alertmanager-*

# # Setup Alertmanager directories
# mkdir -p /etc/alertmanager
# mkdir -p /var/lib/alertmanager

# # Copy Alertmanager files
# cp alertmanager /usr/local/bin/
# cp amtool /usr/local/bin/

# # Create default config if it doesn't exist
# if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
#     cat > /etc/alertmanager/alertmanager.yml << EOF
# global:
#   resolve_timeout: 5m

# route:
#   group_by: ['alertname']
#   group_wait: 30s
#   group_interval: 5m
#   repeat_interval: 1h
#   receiver: 'web.hook'

# receivers:
# - name: 'web.hook'
#   webhook_configs:
#   - url: 'http://127.0.0.1:5001/'

# inhibit_rules:
#   - source_match:
#       severity: 'critical'
#     target_match:
#       severity: 'warning'
#     equal: ['alertname', 'dev', 'instance']
# EOF
# fi

# # Create Alertmanager systemd service
# cat > /etc/systemd/system/alertmanager.service << EOF
# [Unit]
# Description=Alertmanager
# Wants=network-online.target
# After=network-online.target

# [Service]
# User=root
# Group=root
# Type=simple
# ExecStart=/usr/local/bin/alertmanager \
#     --config.file=/etc/alertmanager/alertmanager.yml \
#     --storage.path=/var/lib/alertmanager/

# [Install]
# WantedBy=multi-user.target
# EOF

# # Enable and start Alertmanager
# systemctl daemon-reload
# systemctl enable alertmanager
# systemctl start alertmanager

# echo "Alertmanager installation completed"