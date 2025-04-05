# Простая инфраструктура

## Описание:
Данный проект демонстрирует способ развертывания кластера **Kubernetes** с помощью **Ansible** + **Terraform** в **Yandex Cloud**.
Проект был создан для того, чтобы показать, как инструменты могут взаимодействовать в связке, а также для минимизации человеческого фактора при развертывании инфраструктуры.

## Стек технологий:
- ### Ansible
- ### Terraform (Yandex cloud)
- ### Kubernetes

## Как этим пользоваться:
#### 1. Подготовьте вашу среду и установите зависимости:
  - [Git](https://git-scm.com/downloads)
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip)
  - [Terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform)

#### 2. Клонируйте репозиторий : 
  ``` bash 
  git clone https://github.com/KDS4wexp/Simple_infra.git
  ```
#### 3. Перейдите в проект:
  ``` bash
  cd Simple_infra
  ```
#### 4. [Создайте S3 хранилище](https://yandex.cloud/ru/docs/storage/operations/buckets/create) для хранения состояния инфраструктуры.
#### 5. [Создайте сервисный аккаунт](https://yandex.cloud/ru/docs/iam/operations/sa/create) с ролью **editor** для доступа к S3 хранилищу и [сгенерируйте статический ключ](https://yandex.cloud/ru/docs/iam/operations/authentication/manage-access-keys#create-access-key).
#### 6. Создайте файл **secrets.auto.tfvars** и **secret.backend.tfvars**  и добавьте в него ваши секреты:
  ``` bash
  touch terraform/environments/simple_dev/secrets.auto.tfvars
  touch terraform/environments/simple_dev/secret.backend.tfvars 
  cat <<EOF > ./terraform/environments/simple_dev/secrets.auto.tfvars 
    token-id    = "iam_token" 
    cloud-id    = "идентификатор_облака" 
    folder-id   = "идентификатор_каталога" 
EOF
  cat <<EOF > ./terraform/environments/simple_dev/secret.backend.tfvars 
    bucket      = "название_вашего_хранилища" 
    access_key  = "ключ_доступа" 
    secret_key  = "секретный_ключ" 
EOF
  ```
#### 7. Инициализируйте изменения конфигурации Terraform:
  ``` bash
  terraform -chdir=terraform/environments/simple_dev init -backend-config=secret.backend.tfvars
  ```
#### 8. Замените сертификат и измените доменное имя:
- Измените записи в terraform/environments/simple_dev/main.tf
- Измените доменное имя bastion.**kds4wexp**.ru в ansible/inventories/simple_dev/hosts
#### 9. Создайте пару SSH-ключей:
  ``` bash
  ssh-keygen -t rsa -b 4096
  ```
#### 10. Инициализируйте инфраструктуру:
  ``` bash
  terraform -chdir=terraform/environments/simple_dev init
  terraform -chdir=terraform/environments/simple_dev plan
  terraform -chdir=terraform/environments/simple_dev apply
  ```
#### 11. После успешного развертывания проверьте доступность машин с помощью Ansible:
  ``` bash
  ansible-playbook -i ./ansible/inventories/simple_dev/hosts ./ansible/playbooks/ping.yml
  ```
#### 12. Разворачивание Kubernetes:
- Подготовьте ноды:
  ``` bash
  ansible-playbook -i ./ansible/inventories/simple_dev/hosts ./ansible/playbooks/prepare-nodes.yml
  ```
- Инициализируйте Control plane:
  ``` bash
  ansible-playbook -i ./ansible/inventories/simple_dev/hosts ./ansible/playbooks/init-cluster.yml
  ```
- Подключите рабочие ноды:
  ``` bash
  ansible-playbook -i ./ansible/inventories/simple_dev/hosts ./ansible/playbooks/join-cluster.yml
  ```

  #### **Если необходимо произвести reset кластера существует reset-cluster.yml**.

#### 13. Проверка кластера:
- Подключитесь к мастер-ноде:
  ``` bash
  ssh -o ProxyCommand="ssh -W %h:%p debian@bastion.<Ваше доменное имя>.ru" debian@m-node.private
  ```

- Запросите состояние нод и под:
  ``` bash
  kubectl get nodes
  kubectl get pods -A
  ```
## Итог
С помощью Ansible и Terraform был развернут кластер Kubernetes в Yandex Cloud, а также настроен backend для Terraform.