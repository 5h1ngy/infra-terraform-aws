#!/bin/bash

# AWS Hard Reset Script - USE WITH EXTREME CAUTION
# Questo script elimina tutte le risorse principali nell'account AWS.

set -e

echo "⚠️ Stai per avviare un hard reset dell'account AWS. Tutte le risorse verranno eliminate permanentemente."
read -p "Sei sicuro di voler procedere? Digita 'y' per confermare: " confirmation

if [ "$confirmation" != "y" ]; then
  echo "Aborting. Nessuna modifica effettuata."
  exit 1
fi

# Funzione per eliminare EC2 Instances
delete_ec2_instances() {
  echo "🔹 Eliminazione di tutte le istanze EC2..."
  instance_ids=$(aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text)
  if [ -n "$instance_ids" ]; then
    aws ec2 terminate-instances --instance-ids $instance_ids
    echo "Terminazione delle istanze: $instance_ids"
    # Attendere la terminazione
    aws ec2 wait instance-terminated --instance-ids $instance_ids
    echo "Tutte le istanze EC2 sono state terminate."
  else
    echo "Nessuna istanza EC2 trovata."
  fi
}

# Funzione per eliminare Key Pairs
delete_key_pairs() {
  echo "🔹 Eliminazione di tutte le Key Pairs EC2..."
  key_pairs=$(aws ec2 describe-key-pairs --query "KeyPairs[].KeyName" --output text)
  for key in $key_pairs; do
    aws ec2 delete-key-pair --key-name "$key"
    echo "Key Pair eliminata: $key"
  done
}

# Funzione per eliminare S3 Buckets
delete_s3_buckets() {
  echo "🔹 Eliminazione di tutti i bucket S3..."
  buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
  for bucket in $buckets; do
    echo "Eliminazione del bucket S3: $bucket"
    aws s3 rb "s3://$bucket" --force
    echo "Bucket S3 eliminato: $bucket"
  done
}

# Funzione per eliminare VPCs e risorse associate
delete_vpcs() {
  echo "🔹 Eliminazione di tutte le VPC..."
  vpc_ids=$(aws ec2 describe-vpcs --query "Vpcs[].VpcId" --output text)
  for vpc in $vpc_ids; do
    echo "🔸 Eliminazione delle Subnet nella VPC: $vpc"
    subnet_ids=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --query "Subnets[].SubnetId" --output text)
    for subnet in $subnet_ids; do
      aws ec2 delete-subnet --subnet-id "$subnet"
      echo "Subnet eliminata: $subnet"
    done

    echo "🔸 Eliminazione delle Route Tables nella VPC: $vpc"
    # Identificare la Route Table principale
    main_rt=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc" --query "RouteTables[?Associations[?Main]].RouteTableId" --output text)
    if [ -n "$main_rt" ]; then
      echo "🔸 Designazione di una nuova Route Table come principale (se necessario)"
      # Crea una nuova Route Table
      new_rt=$(aws ec2 create-route-table --vpc-id "$vpc" --query "RouteTable.RouteTableId" --output text)
      echo "Nuova Route Table creata: $new_rt"

      # Associa la nuova Route Table a una subnet (deve essere almeno una subnet rimanente)
      # Se non ci sono subnet, skip
      remaining_subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --query "Subnets[].SubnetId" --output text)
      if [ -n "$remaining_subnets" ]; then
        aws ec2 associate-route-table --route-table-id "$new_rt" --subnet-id $(echo $remaining_subnets | awk '{print $1}')
        echo "Nuova Route Table associata alla subnet: $(echo $remaining_subnets | awk '{print $1}')"
      fi

      # Ora, elimina la Route Table principale
      aws ec2 delete-route-table --route-table-id "$main_rt" || echo "Impossibile eliminare la Route Table principale: $main_rt"
      echo "Route Table principale eliminata: $main_rt"
    fi

    # Elimina le altre Route Tables
    route_table_ids=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc" --query "RouteTables[].RouteTableId" --output text)
    for rt in $route_table_ids; do
      aws ec2 delete-route-table --route-table-id "$rt" || echo "Impossibile eliminare la Route Table: $rt"
      echo "Route Table eliminata: $rt"
    done

    echo "🔸 Eliminazione degli Internet Gateway nella VPC: $vpc"
    igw_ids=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc" --query "InternetGateways[].InternetGatewayId" --output text)
    for igw in $igw_ids; do
      aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$vpc"
      aws ec2 delete-internet-gateway --internet-gateway-id "$igw"
      echo "Internet Gateway eliminato: $igw"
    done

    echo "🔸 Eliminazione della VPC: $vpc"
    aws ec2 delete-vpc --vpc-id "$vpc" || echo "Impossibile eliminare la VPC: $vpc"
    echo "VPC eliminata: $vpc"
  done
}

# Funzione per eliminare Security Groups
delete_security_groups() {
  echo "🔹 Eliminazione di tutti i Security Groups (escluso 'default')..."
  sg_ids=$(aws ec2 describe-security-groups --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
  for sg in $sg_ids; do
    aws ec2 delete-security-group --group-id "$sg" || echo "Impossibile eliminare il Security Group: $sg"
    echo "Security Group eliminato: $sg"
  done
}

# Funzione per eliminare RDS Instances
delete_rds_instances() {
  echo "🔹 Eliminazione di tutte le istanze RDS..."
  rds_instances=$(aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text)
  for rds in $rds_instances; do
    aws rds delete-db-instance --db-instance-identifier "$rds" --skip-final-snapshot
    echo "Eliminazione dell'istanza RDS: $rds"
    aws rds wait db-instance-deleted --db-instance-identifier "$rds"
    echo "Istanza RDS eliminata: $rds"
  done
}

# Funzione per eliminare Lambda Functions
delete_lambda_functions() {
  echo "🔹 Eliminazione di tutte le funzioni Lambda..."
  lambda_functions=$(aws lambda list-functions --query "Functions[].FunctionName" --output text)
  for function in $lambda_functions; do
    aws lambda delete-function --function-name "$function" || echo "Impossibile eliminare la funzione Lambda: $function"
    echo "Funzione Lambda eliminata: $function"
  done
}

# Funzione per eliminare CloudFormation Stacks
delete_cloudformation_stacks() {
  echo "🔹 Eliminazione di tutti gli stack di CloudFormation..."
  stacks=$(aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE DELETE_FAILED --query "StackSummaries[].StackName" --output text)
  for stack in $stacks; do
    aws cloudformation delete-stack --stack-name "$stack"
    echo "Eliminazione dello stack CloudFormation: $stack"
    aws cloudformation wait stack-delete-complete --stack-name "$stack"
    echo "Stack CloudFormation eliminato: $stack"
  done
}

# Funzione per eliminare Route 53 Hosted Zones
delete_hosted_zones() {
  echo "🔹 Eliminazione di tutte le Hosted Zones di Route 53..."
  hosted_zones=$(aws route53 list-hosted-zones --query "HostedZones[].Id" --output text | sed 's/\/hostedzone\///')
  for zone in $hosted_zones; do
    # Rimuovere tutti i record nella Hosted Zone prima di eliminarla
    echo "🔸 Rimozione di tutti i record nella Hosted Zone: $zone"
    # Recuperare tutti i record eccetto SOA e NS
    records=$(aws route53 list-resource-record-sets --hosted-zone-id "$zone" --query "ResourceRecordSets[?Type != 'SOA' && Type != 'NS'].{Name: Name, Type: Type, Values: ResourceRecords[].Value}" --output json)
    
    # Creare una serie di cambiamenti per eliminare i record
    for row in $(echo "${records}" | jq -r '.[] | @base64'); do
      _jq() {
        echo "${row}" | base64 --decode | jq -r "${1}"
      }

      record_name=$(_jq '.Name')
      record_type=$(_jq '.Type')
      record_values=$(_jq '.Values | map("{\"Value\": \"" + . + "\"}") | join(",")')

      # Creare il JSON per il change batch
      change_batch=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "${record_name}",
        "Type": "${record_type}",
        "TTL": 300,
        "ResourceRecords": [
          ${record_values}
        ]
      }
    }
  ]
}
EOF
)

      # Eliminare il record
      aws route53 change-resource-record-sets --hosted-zone-id "$zone" --change-batch "$change_batch"
      echo "Record eliminato: $record_name ($record_type)"
    done

    # Eliminare la Hosted Zone
    aws route53 delete-hosted-zone --id "$zone"
    echo "Hosted Zone eliminata: $zone"
  done
}

# Funzione per eliminare IAM Users (Opzionale)
# ATTENZIONE: Questo eliminerà anche le politiche e gli accessi
delete_iam_users() {
  echo "🔹 Eliminazione di tutti gli utenti IAM (escluso root)..."
  users=$(aws iam list-users --query "Users[?UserName!='root'].UserName" --output text)
  for user in $users; do
    # Rimuovere le politiche gestite e inline
    policies=$(aws iam list-attached-user-policies --user-name "$user" --query "AttachedPolicies[].PolicyArn" --output text)
    for policy in $policies; do
      aws iam detach-user-policy --user-name "$user" --policy-arn "$policy"
      echo "Politica disattaccata dall'utente $user: $policy"
    done

    inline_policies=$(aws iam list-user-policies --user-name "$user" --query "PolicyNames[]" --output text)
    for policy in $inline_policies; do
      aws iam delete-user-policy --user-name "$user" --policy-name "$policy"
      echo "Politica inline eliminata dall'utente $user: $policy"
    done

    # Eliminare l'utente
    aws iam delete-user --user-name "$user" || echo "Impossibile eliminare l'utente IAM: $user"
    echo "Utente IAM eliminato: $user"
  done
}

# Funzione per eliminare Altre Risorse (aggiungi qui altre funzioni se necessario)
# ...

# Esecuzione delle funzioni
delete_ec2_instances
delete_key_pairs
delete_s3_buckets
delete_vpcs
delete_security_groups
delete_rds_instances
delete_lambda_functions
delete_cloudformation_stacks
delete_hosted_zones
# delete_iam_users  # Decommenta se desideri eliminare anche gli utenti IAM

echo "✅ Hard reset dell'account AWS completato con successo!"
