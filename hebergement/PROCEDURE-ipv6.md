# Exposer un serveur auto-hébergé en IPv6 (Linux/Nginx)

## Contexte
Les réseaux mobiles sont majoritairement IPv6-only. Un serveur sans
AAAA est servi via NAT64 (latence, dépendance opérateur). Ajouter
l'IPv6 natif fiabilise l'accès mobile.

## Étapes
1. **IP statique IPv6** (netplan) — figer l'adresse, `accept-ra: true`
2. **Nginx** — `listen [::]:443 ssl http2;` + `listen [::]:80;`
3. **Pare-feu box** — IPv6 entrant TCP 80/443 (⚠️ la DMZ IPv4 ne
   couvre pas l'IPv6)
4. **DNS** — AAAA `@` et `www` vers l'IPv6 du serveur
5. **Validation** — `dig AAAA <domaine> @<dns-authoritaire> +short`,
   curl direct `[ipv6]`, test 4G

## Pièges rencontrés
- DMZ box IPv4 ≠ pare-feu IPv6
- `netplan try` revert après 120 s sans validation (Entrée)
- Cache négatif des résolveurs publics sur l'absence de AAAA