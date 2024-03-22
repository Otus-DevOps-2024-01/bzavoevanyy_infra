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
