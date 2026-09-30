## 6. PROCEDURE-powershell.md — Scripts d'administration

### Bases / prérequis
- Lancer en admin ; `Get-Command -Module <module>` pour explorer ; `Get-Help <cmdlet> -Examples` ; module d'audit : `PSReadLine`, transcript pour les sessions sensibles.

### Recettes utiles pour ce poste
```powershell
# Inventaire des postes du domaine
Get-ADComputer -Filter * -Properties OperatingSystem,LastLogonDate |
  Export-Csv inventaire.csv -NoTypeInformation

# Création en masse des comptes stagiaires (session sept.)
Import-Csv stagiaires.csv | ForEach {
  New-ADUser -Name $_.Nom -SamAccountName $_.Login -AccountPassword `
    (ConvertTo-SecureString $_.Mdp -AsPlainText -Force) `
    -Enabled $true -AccountExpirationDate "2027-06-30"
}

# Rapport disques serveurs
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
  Select PSComputerSystem,DeviceID,`
  @{n='Libre(%)';e={[math]::Round($_.FreeSpace/$_.Size*100,1)}}

# Purge des vieux profils de stagiaires (ex. >90 jours)
Get-CimInstance Win32_UserProfile |
  Where { $_.LastUseTime -lt (Get-Date).AddDays(-90) -and $_.LocalPath -like '*stagiaire*' } |
  Remove-CimInstance

# Reset réseau d'un poste
Get-NetAdapter | Restart-NetAdapter
```

### Bonnes pratiques
Consigner les scripts dans Git · paramétrer (`param()`) plutôt que dupliquer · `Set-StrictMode -Version Latest` · jamais de mot de passe en clair (gMSA / coffre) · commenter en français, nommer en anglais ; côté Linux : équivalents Bash à publier dans le même dossier `scripts/`.