```powershell
<#
.SYNOPSIS
    Inventaire des postes du domaine Active Directory.
.DESCRIPTION
    Exporte la liste des ordinateurs avec OS et dernière connexion,
    vers un CSV horodaté. À planifier ou lancer à la demande.
.NOTES
    Nécessite le module ActiveDirectory (RSAT).
#>

[CmdletBinding()]
param(
    [string]$CheminCsv = ".\inventaire-postes.csv"
)

Set-StrictMode -Version Latest

try {
    $postes = Get-ADComputer -Filter * -Properties Name, OperatingSystem, LastLogonDate |
        Sort-Object Name |
        Select-Object @{n='Nom';e={$_.Name}},
                      @{n='OS';e={$_.OperatingSystem}},
                      @{n='DerniereConnexion';e={$_.LastLogonDate}},
                      @{n='Actif30j';e={ if ($_.LastLogonDate -gt (Get-Date).AddDays(-30)) { 'Oui' } else { 'Non' } }}

    $postes | Export-Csv -Path $CheminCsv -NoTypeInformation -Encoding UTF8

    Write-Host ("{0} postes exportes vers {1}" -f $postes.Count, $CheminCsv)
    Write-Host ("Postes inactifs > 30 jours : {0}" -f ($postes | Where-Object { $_.Actif30j -eq 'Non' }).Count)
}
catch {
    Write-Error "Echec de l'inventaire : $_"
    exit 1
}
```