## 2. PROCEDURE-hyperv.md — Hyper-V (Windows Server)

### Prérequis
Windows Server 2019/2022+, virtualisation activée (BIOS + fonctionnalité Windows), 2 cartes réseau (management + VM), domaine AD recommandé.

### Installation
```powershell
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
```
Via l'assistant : Gérer → Ajouter des rôles ; configurer un commutateur virtuel externe (bound à la carte VM).

### Fonctionnement
- **VMs** : disques VHDX dynamiques ou fixes, checkpoints pour la maintenance, réplication Hyper-V pour le PRA si deux hôtes.
- **Gestion** : Hyper-V Manager ou Windows Admin Center (recommandé) ; SCVMM pour les grosses infra.
- **Réseau** : VLANs sur les vNIC, équipe de cartes (NIC Teaming/Set) pour la redondance.

### Exploitation
Mises à jour hors production via checkpoint → patch → validation → merge du checkpoint ; export mensuel des VM critiques.

### Dépannage — symptômes courants
| Symptôme | Diagnostic | Action |
|---|---|---|
| VM ne démarre pas (erreur Hyper-V-V) | service vmms arrêté | `Restart-Service vmms` |
| "Virtual machine could not start because hypervisor not running" | Hyper-V / VT-x inactif | `bcdedit /set hypervisorlaunchtype auto` puis reboot |
| Réseau VM mort | commutateur virtuel mal mappé | Revérifier la carte physique liée, VLAN |
| Checkpoint orphelin (avhdx) | merge non fait | Fusionner le checkpoint dans le VHDX parent (GUI ou `Merge-VHD`) |
| Disque plein hôte | VHDX dynamiques dérivés | `Optimize-VHD -Mode Full` ; étendre ou migrer |
| Logs | — | Observateur d'événements → journaux Hyper-V-*, `Get-WinEvent -LogName 'Microsoft-Windows-Hyper-V*'` |