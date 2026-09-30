```powershell
<#
.SYNOPSIS
    Rapport d'occupation des disques des serveurs du domaine.
.DESCRIPTION
    Interroge les serveurs (WinRM) et affiche/exporte le % libre par volume.
    Alerte en console sous le seuil defini.
.NOTES
    WinRM doit etre actif sur les cibles. Necessite le module ActiveDirectory.
#>

[CmdletBinding()]
param(
    [int]$SeuilAlerte = 15,       # % libre minimum
    [string]$CheminCsv = ".\rapport-disques.csv"
)

Set-StrictMode -Version Latest

$serveurs = Get-ADComputer -Filter "OperatingSystem -like '*Server*'" -Properties Name |
    Select-Object -ExpandProperty Name

$rapport = foreach ($s in $serveurs) {
    try {
        Get-CimInstance -ComputerName $s -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop |
            Select-Object @{n='Serveur';e={$s}},
                          DeviceID,
                          @{n='Libre(%)';e={[math]::Round($_.FreeSpace/$_.Size*100,1)}},
                          @{n='Taille(GB)';e={[math]::Round($_.Size/1GB,1)}}
    }
    catch {
        Write-Warning "Injoignable (WinRM ?) : $s"
    }
}

$rapport | Sort-Object 'Libre(%)' | Format-Table -AutoSize
$rapport | Export-Csv $CheminCsv -NoTypeInformation -Encoding UTF8

$alertes = $rapport | Where-Object { $_.'Libre(%)' -lt $SeuilAlerte }
if ($alertes) {
    Write-Host ("ATTENTION : {0} volume(s) sous {1}% libre :" -f $alertes.Count, $SeuilAlerte) -ForegroundColor Red
    $alertes | Format-Table Serveur, DeviceID, 'Libre(%)' -AutoSize
}
```