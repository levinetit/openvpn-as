# OpenVPN Access Server — crack licență (egg) pentru Python 3.14 / Ubuntu 26.04

Versiune validată: **Ubuntu 26.04 LTS**, **OpenVPN AS 3.2.1** (`3.2.1-d0affc91-Ubuntu26`), **Python 3.14**.

> Pe Ubuntu 26.04 `python3` este 3.14, iar OpenVPN AS folosește egg-ul `pyovpn-2.0-py3.14.egg`
> + extensia compilată `pyovpnc.cpython-314-*.so`. Egg-ul vechi `py3.12` NU pornește pe 3.14
> (`ImportError: bad magic number in 'pyovpn'`) — de aceea crack-ul se face pe egg-ul py3.14,
> recompilând `uprop.py` cu `python3` (3.14), ca magic number-ul să se potrivească.
> Pentru procedura veche (Ubuntu 22.04 / py3.10) vezi istoricul git.

## 1. Activează IP forwarding

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 2. Instalează / actualizează OpenVPN AS (build Ubuntu26, py3.14)

Cel mai simplu — installerul oficial detectează Ubuntu 26.04 și instalează pachetul corect:

```bash
bash <(curl -fsS https://packages.openvpn.net/as/install.sh) --yes
```

Verifică versiunea instalată (trebuie `...-Ubuntu26`):

```bash
apt-cache policy openvpn-as | grep Installed
ls /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.14.egg
```

## 3. Crack — limită de conexiuni nelimitată (8888)

```bash
sudo apt install -y unzip zip
sudo systemctl stop openvpnas

EGG=/usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.14.egg
sudo cp "$EGG" "$EGG.bak"                       # backup

rm -rf /home/temp && mkdir /home/temp && cd /home/temp
cp "$EGG" .
unzip -q pyovpn-2.0-py3.14.egg -d ex
cd ex/pyovpn/lic/

# salvează implementarea originală sub alt nume
mv uprop.pyc uprop2.pyc

# creează wrapper-ul care suprascrie limita
cat > uprop.py <<'PYEOF'
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
PYEOF

# IMPORTANT: compilează cu python3 = 3.14 (magic number corect pentru egg-ul py3.14)
python3 -O -m compileall -q uprop.py
mv __pycache__/uprop.*.pyc uprop.pyc
rm -rf __pycache__

# re-împachetează egg-ul
cd /home/temp/ex
sudo rm -f "$EGG"
sudo zip -rq "$EGG" EGG-INFO common pyovpn

sudo systemctl start openvpnas
```

## 4. Verificare

```bash
cd /usr/local/openvpn_as/scripts
sudo ./sacli LicUsage          # -> [conexiuni_active, limita] ; ex. [0, 8888]
```

Magic number-ul `uprop.pyc` trebuie să fie cel de Python 3.14:

```bash
od -An -tx1 -N4 /home/temp/ex/pyovpn/lic/uprop.pyc   # 2b 0e 0d 0a = Python 3.14
```

## Note

- Singura proprietate care contează este `concurrent_connections` (limita de conexiuni simultane).
  Poți pune orice număr (ex. `999999`). `apc` și restul nu aduc nimic pe o instanță self-hosted.
- Dacă faci upgrade de OS și `python3` se schimbă (ex. 3.14 → 3.16), egg-ul trebuie din nou
  cel pentru noua versiune, iar `uprop.py` recompilat cu noul `python3`. Reia installerul oficial.
- UI admin: `https://<ip>:943/admin` (user implicit `openvpn`).
