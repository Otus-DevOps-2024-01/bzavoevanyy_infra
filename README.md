# bzavoevanyy_infra

### ДЗ №3 Знакомство с облачной инфраструктурой. Yandex Cloud

1. Для подключения к удаленной ВМ без внешнего IP адреса через bastion host используем следующую команду
    ```shell
    ssh -J appuser@158.160.123.10 appuser@10.128.0.30
    ```
    При этом ключи добавлены в ssh agent

2. Для того, что подключаться командой ```ssh someinternalhost``` нужно в файл ~/.ssh/config добавить:
   ```bash
   Host bastion
      HostName 158.160.123.10
      User appuser
   Host someinternalhost
      HostName 10.128.0.30
      User appuser
      ProxyJump bastion
   ```
3. При конфигурации pritunl добавим хост для Let's Encrypt - 158.160.123.10.nip.io, произойдет выпуск сертификата и браузер не будет ругаться на самоподписанный сертификат

bastion_IP = 158.160.123.10
someinternalhost_IP = 10.128.0.30

### ДЗ №4 Практика управления ресурсамиyandex cloud через yc

1. Для создания ВМ с запуском скриптов и развертыванием приложения выполнить следующую команду:
   ```bash
   yc compute instance create \
    --name reddit-app \
    --hostname reddit-app \
    --memory=4 \
    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
    --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
    --metadata serial-port-enable=1 \
    --zone=ru-central1-a \
    --metadata-from-file user-data=config/cloud-config.yml
   ```
testapp_IP = 51.250.2.166
testapp_port = 9292

### ДЗ №5 Подготовка базового образа VM при помощи Packer

1. Создан файл-шаблон Packer
2. Определен builder type yandex
3. Добавлены provisioners - скрипты для установки всех необходимых зависимостей
4. Шаблон параметризирован - все переменные вынесены в отдельный файл variables.json
5. Произведена сборка образа packer build -var-file=variables.json ./ubuntu16.json
6. Произведена проверка образа - создана ВМ на основе образа и установлено приложение reddit-app

### ДЗ №6 Декларативное описание в виде кода инфраструктуры YC, требуемой для запуска тестового приложения, при помощи Terraform

При помощи конфикурации terraform произведено развертывание тестового приложения на базе ранее созданного базового образа
