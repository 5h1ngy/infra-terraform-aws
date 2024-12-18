terraform destroy -auto-approve; ./scripts/reset.sh;

terraform init; terraform validate; terraform plan; terraform apply -auto-approve;

ssh -i ./data/ssh/id_rsa_terraform ubuntu@16.16.107.234

scp /percorso/del/file utente@16.16.107.234:/percorso/destinazione

sudo systemctl restart nginx;  cat /etc/nginx/nginx.conf;
