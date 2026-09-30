```bash
#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sauvegarde de la configuration d'un hote Proxmox VE
# (fichiers /etc/pve, config reseau, storage) vers un dossier horodate.
# A planifier via cron, ex. :  30 2 * * *  /root/scripts/backup-proxmox-config.sh
# -----------------------------------------------------------------------------
set -euo pipefail

DEST="/var/backups/proxmox-config"
DATE="$(date +%F_%Hh%M)"
ARCHIVE="pve-config_${DATE}.tar.gz"
RETENTION_JOURS=30

mkdir -p "$DEST"

# /etc/pve est pmxcfs : on sauvegarde la source via tar (les fichiers sont lus via FUSE)
tar -czf "${DEST}/${ARCHIVE}" \
    /etc/pve /etc/network/interfaces /etc/fstab \
    /etc/apt/sources.list /etc/apt/sources.list.d/ \
    /etc/hostname /etc/hosts 2>/dev/null

# Purge des archives plus vieilles que RETENTION_JOURS
find "$DEST" -name 'pve-config_*.tar.gz' -mtime "+${RETENTION_JOURS}" -delete

echo "Sauvegarde OK : ${DEST}/${ARCHIVE}"
```