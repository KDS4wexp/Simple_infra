# Простая инфраструктура

## Описание:
Данный прокт предназначен для развертывания простой инфраструктуры для небольших проектов.

## Стек технологий:
- Ansible
- Terraform
- GitLab
- Hashi Vault
- HAProxy

## Как этим ползоваться:
### 1. Подготовте свои среду и установите зависимости
  - [Git](https://git-scm.com/downloads)
  - [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip)
  - [Terraform](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart#install-terraform)

### 2. Сделайте форк этого репозитория: 
Форк можно сделать по кнопке справа вверху в репозитории Github

### 3. Создайте пары ssh ключей для виртуальных машин:
``` bash
ssh-keygen -t rsa -b 4096
```
### 4. [Создайте S3 хранилище](https://yandex.cloud/ru/docs/storage/operations/buckets/create) для хранения состояния инфраструктуры.

### 5. [Создайте сервисный аккаунт](https://yandex.cloud/ru/docs/iam/operations/sa/create) с ролью **editor** для доступа к S3 хранилищу и [сгенерируйте статический ключ](https://yandex.cloud/ru/docs/iam/operations/authentication/manage-access-keys#create-access-key).

### 6. Добавьте секреты в GitHub:
- TOKEN "Ваш IAM token"
- CLOUD "Ваш идентификатор облака"
- FOLDER "Ваш идентификатор каталога"
- BUCKET "Ваше имя s3 хранилища"
- ACCESS_KEY "Ваш сгенерированный ключ доступа"
- SECRET_KEY "Ваш сгенерированный секретный ключ "
- DOMAIN "Ваш домен для сервиса сертификации"
- PUBLIC_SSH_KEY "Ваш публичный SSH ключ"

### 7. Ansible
### После проделанных этапов должна развернуться инфраструктура