
Version: Ubuntu 22.04 Server, OAS 2.14.0

1. **Activarea Forwarding-ului IP după instalarea Ubuntu**
   ```bash
   # nano /etc/sysctl.conf
Adăugați următoarea linie:

bash
Copy code
net.ipv4.ip_forward = 1
Aplicați modificările:

bash
Copy code
# sysctl -p
Instalarea OAS

bash
Copy code
# apt update && apt -y install ca-certificates wget net-tools gnupg
# wget https://as-repository.openvpn.net/as-repo-public.asc -qO /etc/apt/trusted.gpg.d/as-repository.asc
# echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/as-repository.asc] http://as-repository.openvpn.net/as/debian jammy main" > /etc/apt/sources.list.d/openvpn-as-repo.list
# apt update && apt -y install openvpn-as
(Pentru a instala DCO: apt install -y openvpn-dco-dkms (Necesită verificare a parolei după repornire pentru a fi activat))

Crack

bash
Copy code
# sudo apt install python3-pip unzip zip
# systemctl stop openvpnas
# mkdir /home/temp && cd /home/temp
# cp /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg{,.bak}
# cp /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg .
# unzip -q pyovpn-2.0-py3.10.egg 
# cd ./pyovpn/lic/
# mv uprop.pyc uprop2.pyc
# nano uprop.py
Introduceți următorul conținut:

python
Copy code
from pyovpn.lic import uprop2
old_figure = None

def new_figure(self, licdict):
      ret = old_figure(self, licdict)
      ret['concurrent_connections'] = 8888
      return ret

for x in dir(uprop2):
      if x[:2] == '__':
         continue
      if x == 'UsageProperties':
         exec('old_figure = uprop2.UsageProperties.figure')
         exec('uprop2.UsageProperties.figure = new_figure')
      exec('%s = uprop2.%s' % (x, x))
bash
Copy code
# python3 -O -m compileall uprop.py && mv __pycache__/uprop.*.pyc uprop.pyc
# cd ../../
# zip -rq pyovpn-2.0-py3.10.egg ./pyovpn ./EGG-INFO ./common
# mv ./pyovpn-2.0-py3.10.egg /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.10.egg
# systemctl start openvpnas
