## 3. PROCEDURE-active-directory.md — Active Directory

### Prérequis
Windows Server, DNS déjà opérationnel sur la machine, schéma IP planifié, nommage décidé (ex. `formation.local` — éviter `.local` en production réelle si possible, préférer un sous-domaine du domaine public).

### Installation
```powershell
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
Install-ADDSForest -DomainName "formation.example.fr" -InstallDns
```
Poste d'administration : RSAT (Outils d'administration de serveur distant) — **ne jamais administrer l'AD depuis le serveur lui-même** en routine.

### Fonctionnement
- **Utilisateurs/Groupes** : nommage strict (`prenom.nom`), groupes par fonction (`GG-Formateurs-Read`, `GG-Stagiaires`), principe du moindre privilège.
- **GPO** : une GPO = un objectif ; documenter chaque GPO ; filtrage par sécurité ou WMI.
- **OU** : structure par site/type, pas par personne ; délégation fine possible par OU.
- **Droits d'accès** (attendu du poste) : revue trimestrielle des membres des groupes privilégiés (`Get-ADGroupMember "Domain Admins"`), comptes de service gérés (gMSA), comptes stagiaires à durée de vie limitée (date d'expiration).

### Exploitation
Sauvegarde système (Windows Server Backup incluant SYSVOL) ; réplication inter-DC surveillée (`repadmin /replsummary`, `dcdiag`).

### Dépannage — symptômes courants
| Symptôme | Diagnostic | Action |
|---|---|---|
| Impossible de joindre une machine au domaine | DNS client pointe pas sur le DC | Fixer le DNS de la carte sur l'IP du DC, `nltest /dsgetdc:` |
| Mot de passe "refusé" partout pour un utilisateur | compte verrouillé/expiré | `Get-ADUser -Properties LockedOut`, `Unlock-ADAccount` |
| Replication lente / erreurs | `dcdiag`, `repadmin /showrepl` | Forcer `repadmin /syncall`, vérifier NTP du PDC (`w32tm /query /status`) |
| GPO non appliquée | `gpresult /r` sur le poste | Vérifier filtrage, lien OU, temps de réplication ; `gpupdate /force` |
| Lenteurs AD globales | DNS mal configuré client | 90 % des pannes AD = DNS ; vérifier pointeurs, pas de DNS public en secondaire de la carte |

---

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