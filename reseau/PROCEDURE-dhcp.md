## 5. PROCEDURE-dhcp.md — DHCP

### Installation / configuration
- **Windows** : rôle DHCP, autoriser le serveur dans l'AD (`Add-DhcpServerInDC`), créer l'étendue (scope).
- **Linux (isc-dhcp ou Kea)** :
```bash
apt install isc-dhcp-server
# /etc/dhcp/dhcpd.conf : subnet, range, option routers, option domain-name-servers
systemctl restart isc-dhcp-server
```

### Fonctionnement
- Étendues séparées : formateurs, stagiaires, salle A/B, administration, invités.
- **Réservations** par MAC pour imprimantes, bornes, serveurs ; baux courts (2-4 h) pour les salles de formation (rotation rapide des stagiaires).
- Options principales : `003 router` (passerelle), `006 dns`, `015 domain`, `066/067` boot PXE (déploiement d'images).
- Redondance : failover DHCP (Windows) ou deux serveurs avec étendues disjointes.

### Dépannage
| Symptôme | Diagnostic | Action |
|---|---|---|
| Poste en 169.254.x.x (APIPA) | pas de réponse DHCP | `dhcping` / baie d'affectation, vérifier le relai DHCP (ip helper) inter-VLAN |
| Conflit d'IP | deux serveurs DHCP / réservation doublon | `Get-DhcpServerv4ConflictRecord`, désactiver le serveur indésirable |
| Baux épuisés | étendue trop petite / baux trop longs | `Get-DhcpServerv4ScopeStatistics`, élargir l'étendue |
| Une salle sans IP | relai DHCP absent sur le VLAN | Configurer `ip helper-address` sur le switch |
| Audit | — | `Get-DhcpServerv4Lease`, bail.list (`/var/lib/dhcp/dhcpd.leases`) |