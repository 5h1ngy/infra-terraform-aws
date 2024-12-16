terraform destroy -auto-approve; ./scripts/reset.sh;

terraform init; terraform validate; terraform plan; terraform apply -auto-approve;

ssh -i .ssh/id_rsa_terraform ubuntu@13.60.230.28

sudo systemctl restart nginx;  cat /etc/nginx/nginx.conf;