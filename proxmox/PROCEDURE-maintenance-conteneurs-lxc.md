# Maintenance des conteneurs LXC Debian sur Proxmox

**Objectif :** tenir à jour plusieurs conteneurs LXC Debian (reverse proxy, application, base de données) sans y passer ses soirées — correctifs de sécurité automatiques, contrôle mensuel, upgrades maîtrisées, sauvegardes programmées.

**Contexte d'application :** infrastructure type — hôte Proxmox VE 9 (Debian trixie) + conteneurs LXC non privilégiés, un conteneur par service (rp, blog statique, app web, PostgreSQL).

---

## 1. Correctifs de sécurité automatiques (à faire une fois par machine)

Dans **chaque conteneur** et sur **l'hôte** :

```bash
apt update && apt full-upgrade -y      # mettre à jour une première fois
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

À partir de là, les correctifs de sécurité Debian s'appliquent seuls chaque nuit.

**Vérification :**

```bash
systemctl status unattended-upgrades
```

> ⚠️ `unattended-upgrades` ne fait **pas** les montées de version majeures (PHP 8.4 → 8.5, PostgreSQL 15 → 16). C'est voulu : celles-ci passent en manuel, après lecture du rapport mensuel.

---

## 2. Rapport mensuel des mises à jour disponibles

Sur l'hôte, créer `/root/check-updates.sh` :

```bash
#!/bin/bash
# Rapport de mises à jour disponibles sur tous les conteneurs + l'hôte
# Adapter la liste des CT à l'infrastructure réelle
for ct in 200 201 202 203; do
  name=$(pct list | awk -v id=$ct '$1==id {print $3}')
  echo "=== CT $ct ($name) ==="
  pct exec $ct -- bash -c "apt update -qq 2>/dev/null && apt list --upgradable 2>/dev/null | grep -v Listing | head -20"
done
echo "=== Hôte pve ==="
apt update -qq 2>/dev/null && apt list --upgradable 2>/dev/null | grep -v Listing
```

```bash
chmod +x /root/check-updates.sh
./check-updates.sh
```

L'avantage de LXC : `pct exec` lance une commande dans un conteneur **sans y entrer** — le script parcourt toute l'infrastructure depuis l'hôte.

### Automatisation du rapport (cron de l'hôte)

```bash
crontab -e
```

```
0 8 1 * * /root/check-updates.sh > /var/log/check-updates-$(date +\%Y\%m).log 2>&1
```

Un fichier `check-updates-AAAAMM.log` est déposé chaque 1er du mois. On l'ouvre, on voit ce qui attend, on upgrade **manuellement** au moment opportun.

> ⚠️ Ne pas automatiser `apt full-upgrade` complet en cron : upgrader à l'aveugle PHP/PostgreSQL sans supervision, c'est risquer de casser l'app un dimanche sans personne pour le voir.

---

## 3. Upgrade manuel (après lecture du rapport)

Dans chaque conteneur concerné :

```bash
apt update && apt full-upgrade -y
apt autoremove -y
```

Recommandations :

- ne jamais faire la veille d'un événement de l'association ;
- redémarrer le service concerné si nécessaire (`systemctl restart nginx php8.4-fpm postgresql`) ;
- vérifier après coup que le service répond (`curl -I http://127.0.0.1` dans le conteneur).

---

## 4. Sauvegardes vzdump programmées (GUI Proxmox)

Dans l'interface web : **Datacenter → Backup → Add**

- **Mode :** `snapshot` (aucune interruption des conteneurs) ;
- **Jour / heure :** hebdomadaire (ex. dimanche 03:00) ;
- **Rétention :** `keep-last=4` (un mois d'historique) ;
- **Stockage :** un stockage distinct de `local-lvm` si possible (second disque, NFS, ou export vers une autre machine).

Sélectionner tous les conteneurs, valider. C'est tout — Proxmox gère le cycle seul.

**Test de restauration (à faire au moins une fois, c'est ça qui valide une sauvegarde) :**

```bash
vzdump --list                          # voir les archives disponibles
pct restore 900 /var/lib/vz/dump/vzdump-lxc-202-....tar.zst --storage local-lvm
pct start 900 && pct enter 900        # vérifier l'état, puis détruire le CT 900
```

---

## 5. Rappels de durcissement associés (déjà en place, à conserver)

- **fail2ban** : dans le reverse proxy (jails `nginx-botsearch`, `nginx-limit-req`, **sans** jail sshd s'il n'y a pas de SSH dans le conteneur — sinon fail2ban refuse de démarrer : `Have not found any log file for sshd jail`) et sur l'hôte (jail `sshd`).
- **Rate-limiting nginx** : `limit_req_zone $binary_remote_addr zone=perip:10m rate=10r/s;` + `limit_req zone=perip burst=20 nodelay;` dans chaque `location /`.
- **Masquage de version** : `server_tokens off;` dans le bloc `http` de nginx ; `expose_php = Off` dans `php.ini`.
- **Conteneurs non privilégiés** (`--unprivileged 1`), pas de SSH dans les conteneurs applicatifs (administration via `pct enter`).
- **PostgreSQL** : `listen_addresses` sur l'IP interne du conteneur uniquement + règle `pg_hba.conf` limitée à l'IP de l'application.
- **Dépôts Proxmox** : dépôts `enterprise` désactivés (`Enabled: no` dans les fichiers `.sources`) sans abonnement ; dépôt `pve-no-subscription` actif.

---

## Récapitulatif

| Quoi | Comment | Fréquence |
|---|---|---|
| Correctifs sécurité | `unattended-upgrades` (chaque CT + hôte) | automatique, chaque nuit |
| Contrôle global | `/root/check-updates.sh` + cron | mensuel, rapport posé sur l'hôte |
| Upgrades majeures | `apt full-upgrade` manuel après lecture du rapport | quand on décide |
| Sauvegardes | vzdump programmé (GUI) | hebdomadaire, rétention 4 |
| Test de restauration | `pct restore` vers un CT temporaire | au moins une fois, puis annuel |
