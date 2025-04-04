# Простая инфраструктура

## Описание:
Данный проект демонстрирует способ развернуть кластер **Kubernetes** с помощью **Ansible** + **Terraform** в **Yandex Cloud**.
Проект был создан для того, чтобы показать как инструменты могут взаимодействовать в связке, а также чтобы минимизировать человеческий фактор в развертывании инфраструктуры.

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
#### 3. Создайте файл secrets.auto.tfvars и добавьте в него ваши токены:
  ``` bash
  touch Simple_infra/terraform/secrets.auto.tfvars 
  cat <<EOF > secrets.auto.tfvars 
    token-id = "iam_token" 
    cloud-id = "идентификатор_облака" 
    folder-id= "идентификатор_каталога" 
EOF
  ```
#### 4. Перейдите в проект:
  ``` bash
  cd Simple_infra
  ```
#### 5. Замените сертификат и измените доменное имя:
- Измените записи в terraform/environments/simple_dev/main.tf
- Измените доменное имя bastion.**kds4wexp**.ru в ansible/inventories/simple_dev/hosts
#### 6. Создадим пару SSH-ключей:
  ``` bash
  ssh-keygen -t rsa -b 4096
  ```
#### 7. Инициализируйте инфраструктуру:
  ``` bash
  terraform -chdir=terraform/environments/simple_dev init
  terraform -chdir=terraform/environments/simple_dev plan
  terraform -chdir=terraform/environments/simple_dev apply
  ```
#### 8. После успешного развертывания проверьте доступность машин с помощью Ansible:
  ``` bash
  ansible-playbook -i ./ansible/inventories/simple_dev/hosts ./ansible/playbooks/ping.yml
  ```
#### 9. Разворачивание Kubernetes:
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

  #### **Если небходимо произвести reset кластера существует reset-cluster.yml**

#### 10. Проверка кластера:
- Подключитесь к мастер-ноде:
  ``` bash
  ssh -o ProxyCommand="ssh -W %h:%p debian@bastion.<Ваше доменное имя>.ru" debian@m-node.private
  ```

- Запросите состояние нод и под
  ``` bash
  kubectl get nodes
  kubectl get pods -A
  ```
## Итог
С помощью Ansible и Terraform был развернут кластер Kubernetes в Yandex Cloud.