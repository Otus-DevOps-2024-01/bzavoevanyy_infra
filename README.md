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

При помощи конфигурации terraform произведено развертывание тестового приложения на базе ранее созданного базового образа

### ДЗ №7 Создание Terraform модулей для управления компонентами инфраструктуры

Созданы модули terraform для переиспользования в разных конфигурациях, добавлены конфигурации terraform stage и prod

### ДЗ №8 Написание Ansible плейбуков на основе имеющихся bash скриптов

1. Настроил рабочее окружение для выполнения дз, поскольку на локальной машине с macos непросто добиться совместимости по версиям - работу выполняю в докер контейнере from ubuntu:16.04)
2. При первом выполнении плейбука changed=0 так как репозиторий уже склонирован, после удаления репозитория и повторном выполнении плейбука changed=1
3. Добавил скрипт inventory.sh и настроил работу ansible с dynamic inventory, результат выполнения команды ansible all -m ping:
```bash
root@72d5079c77e0:/app/ansible# ansible all -m ping
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
dbserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

### ДЗ №9 Управление настройками хостов и деплой приложения при помощи Ansible.

При выполнении ДЗ выработаны следующие шаги по сборке образов и деплоя приложения

1. Изменен provisioning в packer c bash скриптов на ansible, произведена сборка образов:

   ```bash
   root@72d5079c77e0:/app# packer build -var-file=packer/variables.json packer/app.json
   yandex: output will be in this color.

   ==> yandex: Creating temporary RSA SSH key for instance...
   ==> yandex: Using as source image: fd8q8lhd0sv7jho2p31j (name: "ubuntu-16-04-lts-v20240520", family: "ubuntu-1604-lts")
   ==> yandex: Use provided subnet id e9b9a6g10ev0etmqa25a
   ==> yandex: Creating disk...
   ==> yandex: Creating instance...
   ==> yandex: Waiting for instance with id fhmnc6f35ui74j9rt0dr to become active...
   yandex: Detected instance IP: 158.160.96.172
   ==> yandex: Using SSH communicator to connect: 158.160.96.172
   ==> yandex: Waiting for SSH to become available...
   ==> yandex: Connected to SSH!
   ==> yandex: Provisioning with Ansible...
   yandex: Setting up proxy adapter for Ansible....
   ==> yandex: Executing Ansible: ansible-playbook -e packer_build_name="yandex" -e packer_builder_type=yandex --ssh-extra-args '-o IdentitiesOnly=yes' -e ansible_ssh_private_key_file=/tmp/ansible-key180249590 -i /tmp/packer-provisioner-ansible1002891186 /app/ansible/packer_app.yml
   yandex:
   yandex: PLAY [Install Git, Ruby && Bundler] ********************************************
   yandex:
   yandex: TASK [Gathering Facts] *********************************************************
   yandex: ok: [default]
   yandex:
   yandex: TASK [Install git] *************************************************************
   yandex: changed: [default]
   yandex:
   yandex: PLAY RECAP *********************************************************************
   yandex: default                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   yandex:
   ==> yandex: Stopping instance...
   ==> yandex: Deleting instance...
   yandex: Instance has been deleted!
   ==> yandex: Creating image: reddit-app-base-1717321062
   ==> yandex: Waiting for image to complete...
   ==> yandex: Success image create...
   ==> yandex: Destroying boot disk...
   yandex: Disk has been deleted!
   Build 'yandex' finished after 3 minutes 32 seconds.

   ==> Wait completed after 3 minutes 32 seconds

   ==> Builds finished. The artifacts of successful builds are:
   --> yandex: A disk image was created: reddit-app-base-1717321062 (id: fd85km2hcvviq2n8uat8) with family name reddit-app-base

   root@72d5079c77e0:/app# packer build -var-file=packer/variables.json packer/db.json
   yandex: output will be in this color.

   ==> yandex: Creating temporary RSA SSH key for instance...
   ==> yandex: Using as source image: fd8q8lhd0sv7jho2p31j (name: "ubuntu-16-04-lts-v20240520", family: "ubuntu-1604-lts")
   ==> yandex: Use provided subnet id e9b9a6g10ev0etmqa25a
   ==> yandex: Creating disk...
   ==> yandex: Creating instance...
   ==> yandex: Waiting for instance with id fhmkp1r0sjdpr6cjgljj to become active...
   yandex: Detected instance IP: 178.154.221.1
   ==> yandex: Using SSH communicator to connect: 178.154.221.1
   ==> yandex: Waiting for SSH to become available...
   ==> yandex: Connected to SSH!
   ==> yandex: Provisioning with Ansible...
   yandex: Setting up proxy adapter for Ansible....
   ==> yandex: Executing Ansible: ansible-playbook -e packer_build_name="yandex" -e packer_builder_type=yandex --ssh-extra-args '-o IdentitiesOnly=yes' -e ansible_ssh_private_key_file=/tmp/ansible-key511626257 -i /tmp/packer-provisioner-ansible4062777564 /app/ansible/packer_db.yml
   yandex:
   yandex: PLAY [Install MongoDB 3.2] *****************************************************
   yandex:
   yandex: TASK [Gathering Facts] *********************************************************
   yandex: ok: [default]
   yandex:
   yandex: TASK [Add APT key] *************************************************************
   yandex: changed: [default]
   yandex:
   yandex: TASK [Add APT repository] ******************************************************
   yandex: changed: [default]
   yandex:
   yandex: TASK [Install mongodb package] *************************************************
   yandex: changed: [default]
   yandex:
   yandex: TASK [Configure service supervisor] ********************************************
   yandex: changed: [default]
   yandex:
   yandex: PLAY RECAP *********************************************************************
   yandex: default                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   yandex:
   ==> yandex: Stopping instance...
   ==> yandex: Deleting instance...
   yandex: Instance has been deleted!
   ==> yandex: Creating image: reddit-db-base-1717321546
   ==> yandex: Waiting for image to complete...
   ==> yandex: Success image create...
   ==> yandex: Destroying boot disk...
   yandex: Disk has been deleted!
   Build 'yandex' finished after 2 minutes 50 seconds.

   ==> Wait completed after 2 minutes 50 seconds

   ==> Builds finished. The artifacts of successful builds are:
   --> yandex: A disk image was created: reddit-db-base-1717321546 (id: fd8gf2mu3qf3dsnll746) with family name reddit-db-base


   ```
2. Создаем инстансы при помощи terraform на базе ранее созданных образов reddit-app-base-1717321062 и reddit-db-base-1717321546:

   ```bash
   root@72d5079c77e0:/app/terraform/stage# terraform apply -auto-approve=true

   ...
   module.vpc.yandex_vpc_network.app-network: Creating...
   module.vpc.yandex_vpc_network.app-network: Creation complete after 2s [id=enp8518kvhu6gdbtkoe5]
   module.vpc.yandex_vpc_subnet.app-subnet: Creating...
   module.vpc.yandex_vpc_subnet.app-subnet: Creation complete after 1s [id=e9baaialm5uv06h3ikjf]
   module.app.yandex_compute_instance.app: Creating...
   module.db.yandex_compute_instance.db: Creating...
   module.app.yandex_compute_instance.app: Still creating... [10s elapsed]
   ...
   module.db.yandex_compute_instance.db: Still creating... [1m10s elapsed]
   module.db.yandex_compute_instance.db: Creation complete after 1m12s [id=fhmevj88f4be54b9rfbj]
   module.app.yandex_compute_instance.app: Still creating... [1m20s elapsed]
   module.app.yandex_compute_instance.app: Creation complete after 1m25s [id=fhmv1h381q50qpkfn44o]

   Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

   Outputs:

   external_ip_address_app = "158.160.109.6"
   external_ip_address_db = "158.160.99.87"

   ```

3. Конфигурируем инстансы при помощи ansible:

В процессе выполнения ДЗ разделили плейбук на несколько частей:
```shell
db.yml - сценарий для конфигуазия БД mongodb
app.yml - сценарий для конфигруации приложения
deploy.yml - сценарий для деплоя приложения

site.yml - сценарий для управления всей инфраструктурой
```

Проверяем сценарий site.yml
```shell
root@72d5079c77e0:/app/ansible# ansible-playbook site.yml --check

PLAY [Configure MongoDB] ***************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************
ok: [dbserver]

TASK [Change mongo config file] ********************************************************************************************************************************************
changed: [dbserver]

RUNNING HANDLER [restart mongod] *******************************************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] *******************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************
ok: [appserver]

TASK [Add unit file for Puma] **********************************************************************************************************************************************
changed: [appserver]

TASK [Add config for DB connection] ****************************************************************************************************************************************
changed: [appserver]

TASK [enable puma] *********************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] **********************************************************************************************************************************************
changed: [appserver]

PLAY [Deploy App] **********************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ************************************************************************************************************************
changed: [appserver]

TASK [Bundle install] ******************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] **********************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *****************************************************************************************************************************************************************
appserver                  : ok=9    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
dbserver                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Применяем:

```shell
root@72d5079c77e0:/app/ansible# ansible-playbook site.yml

PLAY [Configure MongoDB] ***************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************
ok: [dbserver]

TASK [Change mongo config file] ********************************************************************************************************************************************
changed: [dbserver]

RUNNING HANDLER [restart mongod] *******************************************************************************************************************************************
changed: [dbserver]

PLAY [Configure App] *******************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************
ok: [appserver]

TASK [Add unit file for Puma] **********************************************************************************************************************************************
changed: [appserver]

TASK [Add config for DB connection] ****************************************************************************************************************************************
changed: [appserver]

TASK [enable puma] *********************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] **********************************************************************************************************************************************
changed: [appserver]

PLAY [Deploy App] **********************************************************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************************************************************
ok: [appserver]

TASK [Fetch the latest version of application code] ************************************************************************************************************************
changed: [appserver]

TASK [Bundle install] ******************************************************************************************************************************************************
changed: [appserver]

RUNNING HANDLER [reload puma] **********************************************************************************************************************************************
changed: [appserver]

PLAY RECAP *****************************************************************************************************************************************************************
appserver                  : ok=9    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
dbserver                   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

4. Проверил работу приложения по адресу 158.160.109.6:9292
