## 7. PROCEDURE-baie-switches.md — Baie informatique & éléments actifs

### Montage de baie (rappel terrain)
- Passerelle et label des câbles des deux côtés ; séparer alimentation et données ; brassage vertical au ras des switchs ; gestion du froid (hot/cold aisle) ; velcro, jamais de colson sur le cuivre.
- Composants : onduleur, PDU, switches (cuivre/access), pare-feu, baie de stockage.

### Switches — configuration type
- IP fixe de management sur VLAN dédié ; SSH activé, telnet et compte par défaut désactivés ; SNMP v3 pour la supervision ; spanning-tree actif ; description de chaque port (`description Salle-12-PC07`).
- Pare-feu : règles par besoin, journalisation des rejets, sauvegardée avant chaque modification.

### Dépannage
| Symptôme | Diagnostic | Action |
|---|---|---|
| Lien coupé | état du port | Raccorder, vérifier le port (flancs du port désactivés ?) |
| Déconnexions aléatoires | erreurs CRC (câble/paire défectueuse) | `show interface counters errors`, recâbler |
| Un VLAN isolé | port en access au lieu de trunk | Corriger le mode du port |
| Débit faible | duplex/speed forcés | Passer en auto sur les deux extrémités |
| Poste non détecté sur la baie | câble mal brabé | Suivre le brassage au testeur / lampe de brassage |