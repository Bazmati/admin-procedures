```bash
#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Veille de securite Debian/Ubuntu : lister les mises a jour disponibles
# et verifier l'etat du service unattended-upgrades.
# Usage : ./veille-maj-securite.sh  (lancer avec un compte pouvant apt)
# exécutables : `chmod +x scripts/*.sh`
# -----------------------------------------------------------------------------
set -euo pipefail

echo "=== Mises a jour disponibles ==="
apt-get update -qq
apt list --upgradable 2>/dev/null | tail -n +2

NB=$(apt list --upgradable 2>/dev/null | tail -n +2 | wc -l)
echo "=> ${NB} paquet(s) a mettre a jour"

echo ""
echo "=== Mises a jour de securite (unattended-upgrades) ==="
if systemctl is-active --quiet unattended-upgrades; then
    echo "Service actif."
else
    echo "ATTENTION : unattended-upgrades inactif - installer :"
    echo "  apt install unattended-upgrades && systemctl enable --now unattended-upgrades"
fi

echo ""
echo "=== Redemarrage requis ? ==="
if [ -f /var/run/reboot-required ]; then
    echo "OUI - planifier un redemarrage."
else
    echo "Non."
fi
```