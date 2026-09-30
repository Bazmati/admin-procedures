```powershell
<#
.SYNOPSIS
    Creation en masse de comptes stagiaires depuis un fichier CSV.
.DESCRIPTION
    Cree les comptes dans l'OU indiquee, avec mot de passe temporaire,
    activation immediate et date d'expiration (fin de session de formation).
.PARAMETER Csv
    Fichier CSV avec colonnes : Nom,Prenom,Login,Mdp
    (Login au format prenom.nom - adaptez a votre convention).
.NOTES
    Prerequis : module ActiveDirectory (RSAT). Exemple de ligne CSV :
    "Nom","Prenom","Login","Mdp"
    "MARTIN","Julie","julie.martin","Form-2026!"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Csv,
    [string]$Ou          = "OU=Stagiaires,DC=formation,DC=example,DC=fr",
    [string]$Groupe      = "GG-Stagiaires",
    [datetime]$Expiration= (Get-Date "2027-06-30")
)

Set-StrictMode -Version Latest

if (-not (Test-Path $Csv)) { Write-Error "Fichier introuvable : $Csv"; exit 1 }

$comptes = Import-Csv -Path $Csv
$cree = 0

foreach ($c in $comptes) {
    $nomComplet = "$($c.Prenom) $($c.Nom)".Trim()

    # Ne pas recreer un compte existant (relance sans risque)
    if (Get-ADUser -Filter "SamAccountName -eq '$($c.Login)'" -ErrorAction SilentlyContinue) {
        Write-Warning "Compte deja existant, ignore : $($c.Login)"
        continue
    }

    New-ADUser -Name $nomComplet `
        -SamAccountName   $c.Login `
        -UserPrincipalName "$($c.Login)@formation.example.fr" `
        -DisplayName      $nomComplet `
        -Path             $Ou `
        -AccountPassword  (ConvertTo-SecureString $c.Mdp -AsPlainText -Force) `
        -Enabled          $true `
        -ChangePasswordAtLogon $true `
        -AccountExpirationDate $Expiration

    Add-ADGroupMember -Identity $Groupe -Members $c.Login
    $cree++
}

Write-Host ("{0} comptes crees dans {1} (expiration le {2:dd/MM/yyyy})." -f $cree, $Groupe, $Expiration)
```