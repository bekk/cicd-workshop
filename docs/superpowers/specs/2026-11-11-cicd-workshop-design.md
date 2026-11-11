# Design: CI/CD-workshop med GitHub Actions

Dato: 2026-11-11

## Formål

En workshop der deltakerne lærer GitHub Actions ved å skrive workflows og
actions selv. Deltakerne forker repoet og jobber i sin egen fork. Materiellet
skal være konsist: README-en sier *hva* som skal oppnås og *hva man kan
forvente*, ikke *hvordan* YAML-en skal se ut. Fasiten ligger separat.

Målgruppe: utviklere som har sett GitHub Actions, men ikke bygget noe selv.
Varighet: ~2 timer kjerne (steg 1–7), pluss valgfrie bonussteg.
Språk: norsk.

## Emner som skal dekkes

Fra oppdragsgivers liste, med steget som dekker hvert punkt:

| Emne | Steg |
|------|------|
| Vanlig kjøring av jobber, valg av runners, shell | 1 |
| Actions fra marketplace, og versjonering av dem | 2 |
| Permissions | 3 |
| Composite actions | 4 |
| Egne actions som kan brukes i andre repoer | 4 + bonus B1 |
| Workflows som kan kalles i andre workflows | 5 |
| Environments, variabler og secrets i environments | 6 |
| Deploy gates basert på environments | 7 |

## Appen

Appen er en kulisse. Den finnes bare for å gi pipelinen noe ekte å bygge,
teste og deploye. Den skal være liten nok til å leses på to minutter og rask
nok til at `npm ci && npm test && npm run build` går på under et minutt i CI.

Stack: Vite + TypeScript + Vitest.

```
index.html
vite.config.ts        base: './'  — gjør bygget uavhengig av repo-navn på Pages
tsconfig.json
package.json
src/
  main.ts             monterer hilsenen i DOM
  config.ts           leser import.meta.env.VITE_APP_GREETING, fallback lokalt
  greeting.ts         ren funksjon: greet(name, greeting) -> string
  greeting.test.ts    3–4 enhetstester, minst én som er lett å brekke med vilje
```

`VITE_APP_GREETING` er den røde tråden: lokalt har den en fallback-verdi, i
steg 6 settes den som environment-variabel, og i steg 7 havner verdien på den
deployede siden. Deltakeren ser altså en environment-variabel vandre hele veien
fra GitHub-settings til nettleseren.

`base: './'` er ikke valgfritt — uten det laster ikke assets på
`https://<bruker>.github.io/<repo>/`, og vi vet ikke hva deltakeren kaller
forken sin.

## Repo-struktur

```
README.md                      hele workshopen
package.json, vite.config.ts, tsconfig.json, index.html
src/
.github/
  workflows/.gitkeep           tom — deltakeren fyller den
solutions/
  README.md                    hvordan bruke fasiten + notater til fasilitator
  steg-1/hello.yml
  steg-2/ci.yml
  steg-3/ci.yml
  steg-4/ci.yml
  steg-4/actions/setup-app/action.yml
  steg-5/ci.yml
  steg-5/build.yml
  steg-6/environments.yml
  steg-7/deploy.yml
  steg-7/README.md             gate-oppsettet, som er ren klikking i Settings
  bonus/
.gitignore
```

`solutions/` ligger utenfor `.github/`, slik at fasit-workflowene ikke kjører
av seg selv i deltakerens fork. Hver fasitfil har kommentarer som forklarer
*hvorfor*, ikke bare *hva*.

## Stegene

Hvert steg i README-en følger samme blokk:

- **Mål** — én setning
- **Oppgave** — punktliste med hva som skal oppnås, ikke ferdig YAML
- **Forventet resultat** — hva deltakeren ser i Actions-fanen eller nettleseren
- **Les mer** — lenke til GitHub-dokumentasjonen
- **Fasit** — `solutions/steg-N/`

### Steg 0 — Kom i gang

Fork repoet, **gjør forken public**, skru på Actions i Actions-fanen, klon,
`npm ci`, `npm run dev`, se appen lokalt.

To ting som må stå tydelig fordi de ellers stopper folk:

1. Required reviewers på environments — altså steg 7 — er bare tilgjengelig på
   offentlige repoer for gratiskontoer. Forken må være public.
2. Workflows er deaktivert i nye forks. Deltakeren må inn på Actions-fanen og
   godkjenne før noe kjører.

### Steg 1 — Din første workflow

`.github/workflows/hello.yml`. Dekker `on: workflow_dispatch` og `on: push`,
`runs-on: ubuntu-latest`, `steps` med `run`, flerlinjers `run` med `|`,
bytte `shell:` på et enkeltsteg, og kontekstvariabler som `${{ github.actor }}`.

Forventet: workflowen dukker opp i Actions-fanen, kan startes manuelt, og
kjører grønt.

### Steg 2 — Bygg og test appen

`.github/workflows/ci.yml` på `push` og `pull_request`. Introduserer
marketplace-actions: `actions/checkout` og `actions/setup-node`. Kjører
`npm ci`, `npm test`, `npm run build`.

Versjonering er hovedpoenget: `@v5` (flytende major-tag), `@5.0.1` (fast
versjon) og `@<sha>` (urokkelig). Forklar hvorfor en tag kan flyttes under
føttene dine, og når det faktisk betyr noe.

Forventet: grønn kjøring. Deltakeren brekker en test med vilje og ser rød
kjøring med testoutput i loggen.

### Steg 3 — Permissions

Lag en jobb som kommenterer på pull requesten. Den skal **feile med 403**
først, fordi `GITHUB_TOKEN` ikke har `pull-requests: write`. Så fikser
deltakeren den.

Dekker `permissions:` på workflow-nivå (`contents: read` som utgangspunkt) og
overstyring på jobb-nivå. Bruk `gh pr comment` med `GH_TOKEN` og `GH_REPO` i
`env:` — da slipper vi både en ekstra action og et `checkout`-steg.

Forventet: først en rød jobb med en 403 i loggen, så en grønn jobb og en
kommentar på pull requesten.

Dette steget er bevisst designet til å feile først. Permissions sitter ikke før
man har sett avvisningen.

### Steg 4 — Composite action

Flytt `setup-node` + `npm ci` inn i `.github/actions/setup-app/action.yml` med
`runs.using: composite` og en `inputs.node-version`. Bruk den fra `ci.yml` med
`uses: ./.github/actions/setup-app`.

To fallgruver som skal nevnes eksplisitt, for de koster ellers ti minutter hver:

- Hvert `run`-steg i en composite action må ha `shell:` satt. Det arves ikke.
- `actions/checkout` må kjøre *før* en lokal action brukes, og kan derfor ikke
  ligge inni den lokale actionen. Den blir værende i workflowen.

Forventet: `ci.yml` blir kortere, kjøringen gir samme resultat som før.

### Steg 5 — Gjenbrukbar workflow

*Kan hoppes over hvis tiden er knapp.* Dette er steget som ryker først.

`.github/workflows/build.yml` med `on: workflow_call`, `inputs` og `outputs`.
Kalles fra `ci.yml` med `jobs.<id>.uses: ./.github/workflows/build.yml` og
`with:`.

Forklar forskjellen fra en composite action: en gjenbrukbar workflow er en
*jobb* (egen runner, egne `permissions`, kan selv ha flere jobber), en
composite action er *steg inni* en jobb.

Forventet: Actions-fanen viser den kalte workflowen som en nøstet jobb.

### Steg 6 — Environments, variabler og secrets

Lag `dev` og `prod` under Settings → Environments. Sett variabelen
`APP_GREETING` med ulik verdi i hver, og en dummy-secret for å se maskering i
loggen.

En jobb med `environment: dev` leser `${{ vars.APP_GREETING }}`. Samme jobb med
`environment: prod` gir en annen verdi — uten at YAML-en endres.

Forventet: to kjøringer, samme workflow, forskjellig output. Secret-verdien
vises som `***` i loggen.

### Steg 7 — Deploy til Pages med gate

Skru på Pages med «GitHub Actions» som kilde. `deploy.yml` med
`permissions: pages: write` og `id-token: write`,
`actions/upload-pages-artifact`, `actions/deploy-pages`, og
`environment: github-pages` med `url:` fra deploy-stegets output.

Bygget kjøres med `VITE_APP_GREETING: ${{ vars.APP_GREETING }}` — variabelen
fra steg 6 havner på siden.

Deretter: legg en required reviewer på `github-pages`-environmentet og kjør på
nytt. Kjøringen stopper og venter på godkjenning. Deltakeren godkjenner sin
egen deploy og ser appen gå live.

Merk i README-en at Pages *tvinger* environment-navnet `github-pages`. Det er
en reell særegenhet verdt å kjenne til, og forklarer hvorfor dette steget ikke
bare gjenbruker `prod` fra steg 6.

Forventet: en kjøring i «Waiting»-tilstand med en Review deployments-knapp, og
etter godkjenning en levende URL.

## Bonussteg

Kort beskrevet, uten håndholding:

- **B1 — Publiser din egen action.** Tagg repoet `v1` og referer actionen som
  `<bruker>/<repo>/.github/actions/setup-app@v1` i stedet for `./`. Viser
  hvordan en action brukes på tvers av repoer.
- **B2 — Matrix.** Flere Node-versjoner, flere operativsystemer, `fail-fast`.
- **B3 — Caching.** `cache: npm` i `setup-node` kontra `actions/cache` manuelt.
- **B4 — Artifacts.** `upload-artifact` i én jobb, `download-artifact` i en
  annen, med `needs:`.
- **B5 — Concurrency.** `concurrency` med `cancel-in-progress` for å drepe
  utdaterte kjøringer på samme branch.
- **B6 — Supply chain.** Pinne alle actions til full SHA, og la Dependabot
  holde dem oppdatert med `package-ecosystem: github-actions`.

## Avgjørelser

**Hvorfor Vite og ikke noe helt uten avhengigheter.** Et `npm ci` gir oss en
grunn til å snakke om caching, og et faktisk byggesteg gir oss noe å deploye.
Uten build-steg mister steg 2 og 7 tyngde.

**Hvorfor fasiten ligger i `solutions/` og ikke på en branch.** Samme mønster
som azure-workshop og gcp-workshop, og det lar deltakeren titte på ett enkelt
steg uten å bytte kontekst.

**Hvorfor steg 3 feiler med vilje.** Det er det eneste stedet i workshopen der
en feilmelding er pedagogikken, ikke et uhell.

## Verifisering

Før workshopen kan regnes som ferdig:

- `npm ci && npm test && npm run build` går grønt lokalt.
- Alle YAML-filer i `solutions/` parser (`yq` eller tilsvarende).
- Majorversjonene på alle marketplace-actions som refereres er sjekket mot
  hva som faktisk er gjeldende nå — ikke gjettet.
- README-en inneholder ingen ferdig YAML for kjernestegene.
