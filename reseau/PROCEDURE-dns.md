## 4. PROCEDURE-dns.md — DNS

### Installation / configuration
- **Sous Windows** : rôle DNS installé avec l'ADDS (zones intégrées à l'AD = réplication automatique).
- **Sous Linux (Bind9)** :
```bash
apt install bind9 bind9-utils
# zone directe + zone inverse dans /etc/bind/zones/
named-checkzone formation.example.fr db.formation.example.fr
systemctl reload bind9
```

### Fonctionnement
- Zone directe (A) + zone **inverse** (PTR) — souvent oubliée, source de lenteurs.
- Enregistrements : A (postes/serveurs), CNAME (alias), MX (mail), SRV (services AD), PTR.
- Clients : pointe ONLY vers le/serveurs DNS internes ; le résolveur interne forward vers le DNS de l'opérateur.
- TTL courts (300 s) pendant les migrations, plus longs (3600+) en régime stable.
- **Cas concret, changement d'opérateur** : avant le basculement d'IP fixe, descendre les TTL, mettre à jour les enregistrements A, contrôler la propagation (`dig @8.8.8.8 +short nom`).

### Dépannage
| Symptôme | Diagnostic | Action |
|---|---|---|
| Un poste ne résout rien | `ipconfig /all` ou `resolvectl status` | Vérifier le serveur DNS de la carte |
| Résolution partielle | zone inverse absente | Créer/peupler la zone PTR |
| Modifs invisibles | cache | `ipconfig /flushdns` / `rndc flushname` ; attendre le TTL |
| `nslookup` fonctionne mais appli non | proxy IPv6 mal configuré | Désactiver IPv6 non maîtrisé ou le configurer proprement |
| Outils | — | `dig`, `nslookup`, `Get-DnsServerZone`, `journalctl -u named` |