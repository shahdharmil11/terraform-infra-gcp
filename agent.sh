sudo chown -R csye6225:csye6225 /etc/google-cloud-ops-agent/

sudo mkdir -p /var/log/webapp
sudo chown -R csye6225:csye6225 /var/log/webapp/

cat <<EOF | sudo tee /etc/google-cloud-ops-agent/config.yaml
logging:
  receivers:
    my-app-receiver:
      type: files
      include_paths:
        - /var/log/webapp/application.log
      record_log_file_path: true
  processors:
    my-app-processor:
      type: parse_json
      time_key: time
      time_format: "%Y-%m-%dT%H:%M:%S.%L%Z"
    move_severity:
      type: modify_fields
      fields:
        severity:
          move_from: jsonPayload.severity
  service:
    pipelines:
      default_pipeline:
        receivers: [my-app-receiver]
        processors: [my-app-processor,move_severity]
EOF

sudo systemctl restart google-cloud-ops-agent