# Bonus

Steg uten egen fil, for de som blir ferdige.

## B1 — Bruk din egen action fra et annet repo

Fram til nå har du referert actionen med `./.github/actions/setup-app`. Den `./`-en
betyr «i dette repoet», og det er grunnen til at du alltid måtte kjøre
`actions/checkout` først.

Actions kan også brukes på tvers av repoer. Da ser referansen slik ut:

```yaml
- uses: <brukernavn>/<repo>/.github/actions/setup-app@v1
```

Prøv det:

1. Tagg forken din:

   ```bash
   git tag v1 && git push origin v1
   ```

2. Bytt ut `./.github/actions/setup-app` med den fulle referansen i `ci.yml`.

3. Push, og se at den fortsatt virker.

Legg merke til at `actions/checkout` nå ikke lenger er nødvendig *for å finne
actionen* — GitHub henter den fra taggen. Du trenger den fortsatt for å få tak
i koden din, men det er en annen grunn.

**Forken må være public** for at dette skal virke. Private repoer kan bare dele
actions innenfor samme organisasjon, og da må det skrus på under
Settings → Actions → General → Access.

> [!TIP]
> Skal en action brukes av andre på ordentlig, legger man den som regel i sitt
> eget repo med `action.yml` i rota. Da blir referansen bare
> `<bruker>/<action-repo>@v1`. Mønsteret er det samme.

## B6 — Pinn actions til SHA

En tag er bare en peker. Den som eier et action-repo kan flytte `v7` til en ny
commit når som helst — også til en som stjeler secretsene dine.

Dette er ikke teoretisk. I mars 2025 ble `tj-actions/changed-files`
kompromittert (CVE-2025-30066): angriperen flyttet *alle* eksisterende
versjonstagger til ondsinnet kode som dumpet secrets i byggeloggen. Over 23 000
repoer brukte actionen. Alle som hadde pinnet til en SHA, var upåvirket.

En commit-SHA kan ikke flyttes. Bytt ut:

```yaml
- uses: actions/checkout@v7
```

med:

```yaml
- uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
```

**Kommentaren er ikke pynt.** En SHA er umulig å lese, så uten `# v7.0.1` vet
verken du eller den neste hvor gammel pinningen er. Verktøy som Dependabot leser
den kommentaren og oppdaterer både SHA og versjonsnummer sammen.

Du finner SHA-en på release-siden til actionen, eller med:

```bash
gh api repos/actions/checkout/git/ref/tags/v7.0.1 --jq '.object.sha'
```

Gjør dette for alle actions i alle workflowene dine, og legg på
`dependabot.yml` fra denne mappa — ellers blir pinningen bare gammel kode
ingen tør å røre.
