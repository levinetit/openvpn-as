# OpenVPN Access Server — license egg crack for Python 3.14 / Ubuntu 26.04

Validated on: **Ubuntu 26.04 LTS**, **OpenVPN AS 3.2.1** (`3.2.1-d0affc91-Ubuntu26`), **Python 3.14**.

> On Ubuntu 26.04 `python3` is 3.14, and OpenVPN AS uses the egg `pyovpn-2.0-py3.14.egg`
> plus the compiled extension `pyovpnc.cpython-314-*.so`. The older `py3.12` egg will NOT
> start on 3.14 (`ImportError: bad magic number in 'pyovpn'`) — so the crack must be applied
> to the py3.14 egg, recompiling `uprop.py` with `python3` (3.14) so the bytecode magic number
> matches. For the legacy procedure (Ubuntu 22.04 / py3.10) see the git history.

## 1. Enable IP forwarding

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 2. Install / update OpenVPN AS (Ubuntu26 build, py3.14)

The easiest way — the official installer detects Ubuntu 26.04 and installs the right package:

```bash
bash <(curl -fsS https://packages.openvpn.net/as/install.sh) --yes
```

Verify the installed version (must be `...-Ubuntu26`):

```bash
apt-cache policy openvpn-as | grep Installed
ls /usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.14.egg
```

## 3. Crack — unlimited connection limit (8888)

```bash
sudo apt install -y unzip zip
sudo systemctl stop openvpnas

EGG=/usr/local/openvpn_as/lib/python/pyovpn-2.0-py3.14.egg
sudo cp "$EGG" "$EGG.bak"                       # backup

rm -rf /home/temp && mkdir /home/temp && cd /home/temp
cp "$EGG" .
unzip -q pyovpn-2.0-py3.14.egg -d ex
cd ex/pyovpn/lic/

# keep the original implementation under a different name
mv uprop.pyc uprop2.pyc

# create the wrapper that overrides the limit
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

# IMPORTANT: compile with python3 = 3.14 (correct magic number for the py3.14 egg)
python3 -O -m compileall -q uprop.py
mv __pycache__/uprop.*.pyc uprop.pyc
rm -rf __pycache__

# repackage the egg
cd /home/temp/ex
sudo rm -f "$EGG"
sudo zip -rq "$EGG" EGG-INFO common pyovpn

sudo systemctl start openvpnas
```

## 4. Verify

```bash
cd /usr/local/openvpn_as/scripts
sudo ./sacli LicUsage          # -> [active_connections, limit] ; e.g. [0, 8888]
```

The `uprop.pyc` magic number must be the Python 3.14 one:

```bash
od -An -tx1 -N4 /home/temp/ex/pyovpn/lic/uprop.pyc   # 2b 0e 0d 0a = Python 3.14
```

## Notes

- The only property that matters is `concurrent_connections` (the simultaneous connection limit).
  You can set any number (e.g. `999999`). `apc` and the rest add nothing on a self-hosted instance.
- If you upgrade the OS and `python3` changes (e.g. 3.14 → 3.16), you need the egg for the new
  version again, and `uprop.py` recompiled with the new `python3`. Re-run the official installer.
- Admin UI: `https://<ip>:943/admin` (default user `openvpn`).
