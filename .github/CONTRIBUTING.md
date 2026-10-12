# Contributing to levinetit/openvpn-as

## Ghid de contribuție

* Asigură-te că faci toate modificările înainte de a crea un Pull Request
* Citește și completează template-ul pentru Pull Request
  * Dacă e o corecție de typo în cod sau documentație, deschide mai întâi un issue
  * Dacă PR-ul rezolvă un issue existent, include `closes #<număr issue>` în mesajul commit-ului
* Pentru întrebări generale, deschide un issue pe GitHub

## Fișiere comune

| Fișier | Utilizare |
| :----: | --- |
| `Dockerfile` | Dockerfile folosit pentru build imagini amd64 |
| `jenkins-vars.yml` | Variabile pentru procesul de build |
| `package_versiffons.txt` | Lista pachetelor instalate și versiunile lor (generat automat) |
| `readme-vars.yml` | Variabile folosite pentru generarea README |

## Testarea modificărilor

```bash
git clone https://github.com/levinetit/openvpn-as.git
cd openvpn-as
docker build --no-cache --pull -t levinetit/openvpn-as:latest .
```

## Actualizarea changelog-ului

Dacă modifici Dockerfile sau scripturile din `root/`, adaugă o intrare în changelog din `readme-vars.yml`:

```yml
changelogs:
  - { date: "DD.MM.YY:", desc: "Descriere modificare" }
```
