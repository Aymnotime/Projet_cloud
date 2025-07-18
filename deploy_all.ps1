
# Chargement des variables d'environnement depuis le fichier .env
Get-Content .env | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        $name = $matches[1]
        $value = $matches[2]
        Set-Variable -Name $name -Value $value
    }
}

terraform init
terraform plan
terraform apply -auto-approve



Write-Host "IP publique de la VM : $VM_IP"

Get-Content $SSH_PUB_KEY_PATH | ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH "${VM_USER}@${VM_IP}" 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'

scp -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ansible_playbook.yaml app.py hosts.ini "${VM_USER}@${VM_IP}:/home/${VM_USER}/"

ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH "${VM_USER}@${VM_IP}" 'sudo apt update && sudo apt install -y ansible sshpass'


ansible-playbook -i hosts.ini ansible_playbook.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host "Déploiement automatisé terminé. Accédez à $APP_URL."
} else {
    ssh-keygen -R $VM_IP
    Write-Host "Une erreur est survenue lors du déploiement. Vérifiez les logs ci-dessus."
}

ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH "${VM_USER}@${VM_IP}"
