# Debug: Mostra la directory corrente e i file presenti
pwd
ls -l

#!/bin/bash

# Controlla se ci sono file Terraform nella directory corrente
if ls *.tf > /dev/null 2>&1; then
  echo "Terraform files found in the current directory."
else
  echo "No Terraform files in the current directory. Changing directory..."
  cd ..
  
  # Controlla di nuovo nella directory superiore
  if ls *.tf > /dev/null 2>&1; then
    echo "Terraform files found in the parent directory."
  else
    echo "No Terraform files found in the parent directory. Exiting."
    exit 1
  fi
fi

# Esegui i comandi Terraform
terraform init;
terraform validate;
terraform plan;
terraform apply;