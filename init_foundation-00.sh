#!bash
echo "Запущен скрипт для передачи ваших секретов в ansible-vault и terraform-vault"

vars=("OAuth" "cloudId" "folderId" "bucket" "accessKey" "secretKey")

for var in ${vars[@]} 
do
  read -p "Введите ваш $var: " value
  declare "$var=$value"
done

read -p "Придумайте пароль к вашему ansible-vault:" value
declare "${ansible-pass}=$value"

exit 0