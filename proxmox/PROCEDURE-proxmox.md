## 1. PROCEDURE-proxmox.md — Proxmox VE

### Prérequis
- Serveur x86_64 avec virtualisation (Intel VT-x / AMD-V) activée dans le BIOS
- 2 disques minimum (1 système, 1 stockage VM), idéalement ZFS ou LVM
- ISO Proxmox VE (dernière version majeure), accès réseau, NTP

### Installation
1. Démarrer sur l'ISO, suivre l'assistant : disque cible, pays, mot de passe root, interface réseau d'administration (IP fixe, passerelle, DNS).
2. Après redémarrage, se connecter à `https://<ip>:8006`.
3. **Post-installation obligatoire** : retirer le dépôt enterprise (`# sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/pve-enterprise.list`) et ajouter le dépôt no-subscription, puis `apt update && apt full-upgrade`.
4. Créer un utilisateur d'administration dédié ou utiliser le realm AD ; éviter l'usage quotidien de root.
5. Vérifier le stockage : Datacenter → Storage ; ajouter un stockage de backups (NFS/CIFS/PBS) distinct des VM.

### Fonctionnement
- **VM** : réserver CPU/RAM avec parcimonie, activer l'agent QEMU (Guest Agent) pour arrêts propres et snapshots cohérents.
- **Conteneurs LXC** : plus légers, parfaits pour services réseau (DNS, DHCP, supervision). Template : `pveam` ou GUI.
- **Cluster** : joindre plusieurs nœuds (`Datacenter → Cluster → Create/Join`) — attention, un cluster ne se défait pas facilement : réserver cet usage aux cas réels.
- **Mises à jour** : nœud par nœud, en migrant les VM à chaud (`qm migrate --online`) si cluster.

### Exploitation / sauvegardes
- Tâche de backup automatique : Datacenter → Backup (mode snapshot, rétention 7-30 j), idéalement vers **Proxmox Backup Server** avec déduplication.
- Test de restauration trimestriel : une sauvegarde jamais restaurée n'existe pas.

### Dépannage — symptômes courants
| Symptôme | Diagnostic | Action |
|---|---|---|
| UI web inaccessible | `systemctl status pveproxy pvedaemon` | Redémarrer le service ; vérifier le port 8006 et le pare-feu |
| VM ne démarre pas : "KVM not available" | VT-x désactivé ou module pas chargé (`lsmod \| grep kvm`) | Activer VT-x en BIOS, `modprobe kvm_intel` |
| VM bloquée ("lock") | `qm status <vmid>` | `qm unlock <vmid>` après vérification |
| Stockage plein | `pvesm status`, `df -h` | Nettoyer snapshots/ISO, étendre LVM/ZFS |
| Latence réseau VM | driver virtio absent | Installer qemu-guest-agent et utiliser des interfaces virtio |
| Logs | — | `/var/log/pve/tasks`, `journalctl -u pve*` |

### Bonnes pratiques
Snapshot avant chaque modification majeure · backups hors du serveur testés · séparer les VLANs mgmt/vm/backup · NTP synchronisé (indispensable au cluster).

---