# 🖥️ Admin Procedures — Procédures d'administration systèmes &amp; réseaux

Bienvenue ! Ce dépôt rassemble un ensemble de **procédures d'exploitation** couvrant l'administration d'une infrastructure mixte **Windows / Linux virtualisée** : installation, fonctionnement, exploitation et dépannage.

Il s'agit de procédures que j'utilise et enrichis dans la pratique : chaque retour d'expérience me permet de les compléter — l'historique Git en témoigne.

## 📚 Contenu


| Dossier             | Procédure                                                          | Contenu                                                        |
| ------------------- | ------------------------------------------------------------------ | -------------------------------------------------------------- |
| `proxmox/`          | [Proxmox VE](proxmox/PROCEDURE-proxmox.md)                         | Installation, VM/LXC, cluster, sauvegardes, dépannage          |
| `hyperv/`           | [Hyper-V](hyperv/PROCEDURE-hyperv.md)                              | Rôle Hyper-V, commutateurs virtuels, checkpoints, réplication  |
| `active-directory/` | [Active Directory](active-directory/PROCEDURE-active-directory.md) | Forêt AD, OU, GPO, gestion des droits, comptes stagiaires      |
| `reseau/`           | [DNS](reseau/PROCEDURE-dns.md) · [DHCP](reseau/PROCEDURE-dhcp.md)  | Zones, réservations, étendues, relais, pannes classiques       |
| `scripts/`          | [Scripts d'administration](scripts/PROCEDURE-powershell.md)        | PowerShell (et Bash) : recettes prêtes à l'emploi              |
| `materiel/`         | [Baie &amp; éléments actifs](materiel/PROCEDURE-baie-switches.md)  | Montage de baie, switches, pare-feu, dépannage réseau physique |
| `exploitation/`     | [Gestion d'incidents](exploitation/PROCEDURE-incidents.md)         | Processus d'incident, checklist de préparation de salle        |
| `hebergement/`      | [IPV6](hebergement/PROCEDURE-ipv6.md)                              | Exposer un serveur auto-hébergé en IPv6 (Linux/Nginx)          |

## 🧭 Format des procédures

Chaque procédure suit toujours le même plan, pour être exploitable **pendant** une intervention :

1. **Prérequis** — ce qu'il faut avant de commencer
2. **Installation** — mise en place pas à pas
3. **Fonctionnement** — concepts clés et opérations courantes
4. **Exploitation** — sauvegardes, mises à jour, surveillance
5. **Dépannage** — tableau symptôme → diagnostic → action
6. **Bonnes pratiques** — les habitudes qui évitent les incidents

## 🛠️ Environnement concerné

- **Hyperviseurs** : Proxmox VE (quotidien), Hyper-V
- **OS serveurs** : Windows Server (AD DS, DNS, DHCP, fichiers), Linux (Debian/Ubuntu — Bind9, isc-dhcp, services web)
- **Postes** : Windows (domaine), Linux (bureautique et technique)
- **Matériel** : baies informatiques, switches administrables, pare-feu, onduleurs
- **Scripting** : PowerShell, Bash

## ✅ Philosophie

- **Écrit pendant qu'on dépanne** : une procédure qui n'est pas issue d'un cas réel n'est pas fiable.
- **Une seule chose à la fois** : chaque étape de diagnostic est documentée pour être rejouable.
- **Le point d'entrée est le symptôme** : les tableaux de dépannage se lisent en 30 secondes, gants sur le clavier.
- **Les sauvegardes qui ne sont jamais restaurées n'existent pas.**

## 📜 Licence

MIT — réutilisez librement, mention appréciée.

## 📇 À propos

Basile Malin — administrateur systèmes &amp; réseaux / développeur.  
Profil : [bazmati.github.io/basile-malin-cv-2026](https://bazmati.github.io/basile-malin-cv-2026/)

> ⚠️ Ces procédures sont fournies à titre indicatif : adaptez-les à votre environnement et testez toujours en environnement hors production avant généralisation.