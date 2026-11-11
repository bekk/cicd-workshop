# CI/CD-workshop Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Et forkbart repo der deltakerne skriver GitHub Actions-workflows selv i sju steg, med en konsis norsk README og en komplett fasit per steg.

**Architecture:** En bevisst kjedelig Vite-app er kulissen. Deltakeren starter med tom `.github/workflows/` og bygger opp pipelinen steg for steg, fra `echo` til en gated Pages-deploy. README-en sier hva som skal oppnås og hva man skal se; fasiten ligger i `solutions/steg-N/`, utenfor `.github/`, så den ikke kjører av seg selv.

**Tech Stack:** Vite 8, Vitest 5, TypeScript 7, Node 24 i CI. `yq` og `actionlint` brukes lokalt til å verifisere fasiten.

**Spec:** `docs/superpowers/specs/2026-11-11-cicd-workshop-design.md`

## Global Constraints

- Alt deltakerrettet materiell er på **norsk**. Kode, YAML-nøkler og filnavn er på engelsk.
- README-en inneholder **ingen ferdig YAML for kjernestegene** (steg 1–7). Bonussteg kan ha korte fragmenter.
- Action-versjoner er verifisert mot GitHub 2026-11-11 og skal brukes nøyaktig slik:
  `actions/checkout@v7`, `actions/setup-node@v7`, `actions/upload-pages-artifact@v5`,
  `actions/deploy-pages@v5`, `actions/cache@v6`, `actions/upload-artifact@v7`,
  `actions/download-artifact@v8`.
- Full SHA for `actions/checkout@v7.0.1` er `3d3c42e5aac5ba805825da76410c181273ba90b1` — brukes der planen ber om et SHA-eksempel.
- `node-version: 24` i alle workflows. Matrix-bonusen bruker `[22, 24, 26]`.
- `.github/workflows/` i dette repoet skal være **tom** (kun `.gitkeep`) når workshopen deles ut.
- Hver fasitfil starter med en kommentarblokk som forklarer *hvorfor*, ikke bare *hva*.
- Fasit valideres med `actionlint`, ikke bare med en YAML-parser.

## Review Focus

- **Fork med annet navn enn `cicd-workshop`** → Pages-URL blir `/<annet-navn>/` og absolutte asset-stier gir 404. Dekkes av `base: './'`; testes i Task 1 ved å asserte at `dist/index.html` ikke inneholder `src="/`.
- **`VITE_APP_GREETING` ikke satt** (lokal kjøring, eller en jobb som glemmer `env:`) → siden må vise fallback-teksten, aldri `undefined`. Testes i Task 1.
- **Fasit som parser som YAML, men ikke er en gyldig workflow** → deltakeren kopierer den inn og får en kryptisk feil. `actionlint` i Task 6, ikke bare `yq`.
- **`npm ci` uten committet lockfile** → steg 2 feiler for alle samtidig. `package-lock.json` må committes i Task 1.
- **Composite action uten `shell:` på `run`-steg** → feiler først i deltakerens fork. `actionlint` fanger det; Task 3 asserter det eksplisitt.

---

### Task 1: Appen

**Files:**
- Create: `package.json`, `tsconfig.json`, `vite.config.ts`, `index.html`
- Create: `src/greeting.ts`, `src/greeting.test.ts`, `src/config.ts`, `src/main.ts`
- Modify: `.gitignore` (finnes allerede)

**Interfaces:**
- Produces: `greet(name: string, greeting: string): string` i `src/greeting.ts`.
  `resolveGreeting(env: { VITE_APP_GREETING?: string }): string` i `src/config.ts`.
  npm-scriptene `dev`, `build`, `test`, `preview`.

- [ ] **Step 1: Initier prosjektet og installer avhengigheter**

```bash
npm init -y
npm install -D vite@^8 vitest@^5 typescript@^7
```

Sett `"type": "module"` og `"private": true` i `package.json`. Scripts:
`dev` = `vite`, `build` = `vite build`, `preview` = `vite preview`,
`test` = `vitest run`, `test:watch` = `vitest`, `typecheck` = `tsc --noEmit`.
`typecheck` er det som gjør `tsconfig.json` meningsfull, og er noe bonusstegene kan legge til i CI.

- [ ] **Step 2: Skriv de feilende testene**

I `src/greeting.test.ts`:

```ts
import { describe, expect, it } from 'vitest'
import { greet } from './greeting'
import { resolveGreeting } from './config'

describe('greet', () => {
  it('setter sammen hilsen og navn', () => {
    expect(greet('Ada', 'Hei')).toBe('Hei, Ada!')
  })

  it('trimmer whitespace rundt navnet', () => {
    expect(greet('  Ada  ', 'Hei')).toBe('Hei, Ada!')
  })

  it('faller tilbake til "verden" for tomt navn', () => {
    expect(greet('   ', 'Hei')).toBe('Hei, verden!')
  })
})

describe('resolveGreeting', () => {
  it('bruker VITE_APP_GREETING når den er satt', () => {
    expect(resolveGreeting({ VITE_APP_GREETING: 'Hallo fra prod' })).toBe('Hallo fra prod')
  })

  it('faller tilbake når variabelen mangler', () => {
    expect(resolveGreeting({})).toBe('Hei fra localhost')
  })

  it('faller tilbake når variabelen er tom', () => {
    expect(resolveGreeting({ VITE_APP_GREETING: '' })).toBe('Hei fra localhost')
  })
})
```

- [ ] **Step 3: Kjør testene og se at de feiler**

Run: `npm test`
Expected: FAIL — `Failed to resolve import "./greeting"`.

- [ ] **Step 4: Implementer `greet` og `resolveGreeting`**

`src/greeting.ts` eksporterer `greet(name: string, greeting: string): string`.
`src/config.ts` eksporterer `resolveGreeting(env: { VITE_APP_GREETING?: string }): string`
med fallback-strengen `'Hei fra localhost'` (eksakt, testen pinner den).

- [ ] **Step 5: Kjør testene og se at de passerer**

Run: `npm test`
Expected: PASS, 6 tester.

- [ ] **Step 6: Koble appen til DOM**

`index.html` med `<div id="app"></div>` og `<script type="module" src="/src/main.ts">`.
`src/main.ts` kaller `resolveGreeting(import.meta.env)` og `greet('verden', ...)`, og
skriver resultatet inn i `#app`. Siden skal også vise en kort setning om at teksten
styres av `VITE_APP_GREETING`, slik at steg 6–7 gir mening visuelt.

`vite.config.ts` setter `base: './'`.

- [ ] **Step 7: Verifiser bygget og de relative stiene**

```bash
npm run build
grep -q 'assets/' dist/index.html || { echo "FANT INGEN ASSETS"; exit 1; }
grep -qE '(src|href)="/' dist/index.html && { echo "ABSOLUTT STI"; exit 1; }
echo RELATIVE_OK
```
Expected: `RELATIVE_OK`. En absolutt `src="/` eller `href="/` i `dist/index.html` betyr at `base` ikke er satt.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "Legg til workshop-appen med tester"
```

---

### Task 2: Fasit for steg 1–3

**Files:**
- Create: `solutions/steg-1/hello.yml`
- Create: `solutions/steg-2/ci.yml`
- Create: `solutions/steg-3/ci.yml`

**Interfaces:**
- Consumes: npm-scriptene fra Task 1.
- Produces: `ci.yml` som Task 3 bygger videre på.

- [ ] **Step 1: Skriv `solutions/steg-1/hello.yml`**

Må inneholde, fordi README-ens steg 1 ber om hvert av dem:
`on: workflow_dispatch` og `on: push` med `branches: [main]`; `runs-on: ubuntu-latest`;
ett enkelt `run`-steg som bruker `${{ github.actor }}`; ett flerlinjers `run` med `|`;
ett steg med `shell: pwsh` for å vise at shell kan byttes per steg.

- [ ] **Step 2: Skriv `solutions/steg-2/ci.yml`**

`on: [push, pull_request]`. Én jobb `build` på `ubuntu-latest` med
`actions/checkout@v7`, `actions/setup-node@v7` (`node-version: 24`, `cache: npm`),
så `npm ci`, `npm test`, `npm run build`.

Kommentarblokken øverst må vise alle tre versjoneringsformene som README-en spør om:
`@v7`, `@v7.0.1` og `@3d3c42e5aac5ba805825da76410c181273ba90b1`, med én linje om når
hver av dem er riktig valg.

- [ ] **Step 3: Skriv `solutions/steg-3/ci.yml`**

Steg 2 pluss: `permissions: contents: read` på workflow-nivå, og en jobb `comment`
med `needs: build`, `if: github.event_name == 'pull_request'`, og
`permissions: { contents: read, pull-requests: write }` på jobbnivå.

Steget kjører `gh pr comment "${{ github.event.number }}" --body "..."` med
`GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}` og `GH_REPO: ${{ github.repository }}` i `env:`.
`GH_REPO` er det som gjør at jobben ikke trenger `actions/checkout`.

Kommentaren i filen må si hva som skjer *uten* `pull-requests: write`: `gh` feiler
med HTTP 403, og det er den feilen README-en ber deltakeren fremprovosere først.

- [ ] **Step 4: Verifiser med actionlint**

Run: `actionlint solutions/steg-1/hello.yml solutions/steg-2/ci.yml solutions/steg-3/ci.yml`
Expected: ingen output, exit 0.

- [ ] **Step 5: Commit**

```bash
git add solutions/steg-1 solutions/steg-2 solutions/steg-3
git commit -m "Legg til fasit for steg 1-3"
```

---

### Task 3: Fasit for steg 4–5

**Files:**
- Create: `solutions/steg-4/actions/setup-app/action.yml`
- Create: `solutions/steg-4/ci.yml`
- Create: `solutions/steg-5/build.yml`
- Create: `solutions/steg-5/ci.yml`

**Interfaces:**
- Consumes: `solutions/steg-3/ci.yml` fra Task 2.
- Produces: composite-actionen `setup-app` med input `node-version` (default `'24'`),
  og den gjenbrukbare workflowen `build.yml` med input `node-version` (type `string`,
  default `'24'`) og output `test-count`.

- [ ] **Step 1: Skriv composite-actionen**

`solutions/steg-4/actions/setup-app/action.yml`: `name`, `description`,
`inputs.node-version` (`required: false`, `default: '24'`),
`runs.using: composite` med `actions/setup-node@v7` og et `npm ci`-steg som
**har `shell: bash`**.

Kommentaren må slå fast de to fallgruvene: `shell:` arves ikke i composite actions, og
`actions/checkout` kan ikke ligge her fordi actionen selv lastes fra det utsjekkede repoet.

- [ ] **Step 2: Skriv `solutions/steg-4/ci.yml`**

Som steg 3, men `setup-node` + `npm ci` er byttet ut med
`uses: ./.github/actions/setup-app` med `with: node-version: '24'`.
`actions/checkout@v7` blir værende som første steg.

- [ ] **Step 3: Skriv `solutions/steg-5/build.yml`**

`on.workflow_call` med `inputs.node-version` (`type: string`, `default: '24'`) og
`outputs.test-count` som mappes fra et jobb-output. Jobben gjør checkout, bruker
composite-actionen, og kjører test og build.

- [ ] **Step 4: Skriv `solutions/steg-5/ci.yml`**

Kaller den gjenbrukbare workflowen: `jobs.build.uses: ./.github/workflows/build.yml`
med `with:`. `comment`-jobben beholdes med `needs: build` og leser
`${{ needs.build.outputs.test-count }}` inn i kommentarteksten.

Kommentaren forklarer forskjellen fra en composite action: en gjenbrukbar workflow er en
jobb med egen runner og egne `permissions`; en composite action er steg inni en jobb.

- [ ] **Step 5: Verifiser med actionlint, og assert `shell:` eksplisitt**

Run: `actionlint solutions/steg-4/ci.yml solutions/steg-5/*.yml && yq -e '.runs.steps[] | select(.run) | .shell' solutions/steg-4/actions/setup-app/action.yml`
Expected: actionlint gir exit 0, og `yq` skriver `bash` for hvert `run`-steg.

- [ ] **Step 6: Commit**

```bash
git add solutions/steg-4 solutions/steg-5
git commit -m "Legg til fasit for steg 4-5"
```

---

### Task 4: Fasit for steg 6–7

**Files:**
- Create: `solutions/steg-6/environments.yml`
- Create: `solutions/steg-7/deploy.yml`
- Create: `solutions/steg-7/README.md`

**Interfaces:**
- Consumes: composite-actionen fra Task 3.
- Produces: deployet som README-ens steg 7 beskriver.

- [ ] **Step 1: Skriv `solutions/steg-6/environments.yml`**

`on: workflow_dispatch` med en `choice`-input `environment` (`dev`/`prod`).
Én jobb med `environment: ${{ inputs.environment }}` som echoer
`${{ vars.APP_GREETING }}` og viser at `${{ secrets.DEPLOY_TOKEN }}` maskeres til `***`.

Kommentaren må si at `vars` og `secrets` med samme navn får ulik verdi avhengig av
hvilket environment jobben kjører i, uten at YAML-en endres.

- [ ] **Step 2: Skriv `solutions/steg-7/deploy.yml`**

`on: push` på `main` + `workflow_dispatch`.
`permissions: { contents: read, pages: write, id-token: write }`.
`concurrency: { group: pages, cancel-in-progress: false }`.
Jobben har `environment: { name: github-pages, url: "${{ steps.deployment.outputs.page_url }}" }`
og stegene: `actions/checkout@v7` → `./.github/actions/setup-app` → `npm run build` med
`VITE_APP_GREETING: ${{ vars.APP_GREETING }}` i `env:` →
`actions/upload-pages-artifact@v5` med `path: dist` →
`actions/deploy-pages@v5` med `id: deployment`.

Kommentaren må forklare hvorfor `id-token: write` trengs, og at environment-navnet
`github-pages` er påkrevd av Pages — det kan ikke hete `prod`.

- [ ] **Step 3: Skriv `solutions/steg-7/README.md`**

Gate-oppsettet er ren klikking og har ingen YAML. Dokumenter rekkefølgen:
Settings → Pages → Source: GitHub Actions; deretter Settings → Environments →
`github-pages` → Required reviewers → legg til seg selv → Save.
Nevn at variabelen `APP_GREETING` også må settes på `github-pages`, ikke bare på
`dev`/`prod` fra steg 6, og hvorfor.

- [ ] **Step 4: Verifiser med actionlint**

Run: `actionlint solutions/steg-6/environments.yml solutions/steg-7/deploy.yml`
Expected: ingen output, exit 0.

- [ ] **Step 5: Commit**

```bash
git add solutions/steg-6 solutions/steg-7
git commit -m "Legg til fasit for steg 6-7"
```

---

### Task 5: Bonusfasit og fasilitatornotater

**Files:**
- Create: `solutions/bonus/matrix.yml`, `solutions/bonus/cache.yml`,
  `solutions/bonus/artifacts.yml`, `solutions/bonus/concurrency.yml`,
  `solutions/bonus/dependabot.yml`
- Create: `solutions/bonus/README.md` (dekker B1, som er tagging og ikke en fil)
- Create: `solutions/README.md`

- [ ] **Step 1: Skriv bonusfilene**

`matrix.yml`: `strategy.matrix` over `node: [22, 24, 26]` og `os: [ubuntu-latest, windows-latest]`, med `fail-fast: false`.
`cache.yml`: `actions/cache@v6` manuelt, ved siden av en kommentar om at `cache: npm` i `setup-node` som regel holder.
`artifacts.yml`: `actions/upload-artifact@v7` i én jobb, `actions/download-artifact@v8` i en jobb med `needs:`.
`concurrency.yml`: `concurrency` med `group: ${{ github.workflow }}-${{ github.ref }}` og `cancel-in-progress: true`.
`dependabot.yml`: `package-ecosystem: github-actions`, ukentlig.

`solutions/bonus/README.md` beskriver to ting uten egen fil:
B1 — tagg forken `v1`, og referer actionen som
`<bruker>/<repo>/.github/actions/setup-app@v1` i stedet for `./.github/actions/setup-app`.
Nevn at dette krever at forken er public.
B6 — bytt alle `@v7`-referanser mot full SHA, med
`actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1` som mønster, og
forklar hvorfor kommentaren med versjonsnummeret er viktig når SHA-en er ulesbar.

- [ ] **Step 2: Skriv `solutions/README.md`**

Forklar at fasiten ligger utenfor `.github/` med vilje, hvor hver fil skal kopieres,
og at `.yml`-filene under `steg-4/actions/` skal til `.github/actions/`.
Legg til en kort seksjon «For fasilitator»: tidsbudsjett per steg, at steg 5 er det som
ryker først ved dårlig tid, og de to tingene som stopper folk (public fork, Actions
deaktivert i nye forks).

- [ ] **Step 3: Verifiser**

Run: `actionlint solutions/bonus/matrix.yml solutions/bonus/cache.yml solutions/bonus/artifacts.yml solutions/bonus/concurrency.yml && yq -e '.updates[0].package-ecosystem' solutions/bonus/dependabot.yml`
Expected: actionlint exit 0, `yq` skriver `github-actions`.

- [ ] **Step 4: Commit**

```bash
git add solutions
git commit -m "Legg til bonusfasit og fasilitatornotater"
```

---

### Task 6: README

**Files:**
- Create: `README.md`
- Create: `.github/workflows/.gitkeep`

**Interfaces:**
- Consumes: alle fasitfilene, som README-en lenker til per steg.

- [ ] **Step 1: Skriv README-en**

Struktur: tittel og intro, «Før du starter» (verktøy), steg 0, deretter steg 1–7, så bonus.

Hvert steg 1–7 er samme blokk, i denne rekkefølgen:
**Mål** (én setning) · **Oppgave** (punktliste med hva, ikke hvordan) ·
**Forventet resultat** (hva som sees i Actions-fanen eller nettleseren) ·
**Les mer** (lenke til docs.github.com) · **Fasit** (lenke til `solutions/steg-N/`).

Innholdet i hvert steg følger spec-ens stegbeskrivelser. Steg 0 må inneholde de to
advarslene: forken må være **public** (ellers finnes ikke required reviewers), og
workflows er deaktivert i nye forks til deltakeren godkjenner dem i Actions-fanen.
Steg 5 merkes «kan hoppes over hvis tiden er knapp».

- [ ] **Step 2: Verifiser at README-en ikke lekker fasit**

Run: `awk '/^## Steg 1/,/^## Bonus/' README.md | grep -nE '^\s*(runs-on|uses|permissions):' && echo LEKKASJE || echo INGEN_YAML_OK`
Expected: `INGEN_YAML_OK`.

- [ ] **Step 3: Verifiser at hvert steg har alle fire blokkene**

Run: `for n in 1 2 3 4 5 6 7; do c=$(awk "/^## Steg $n /,/^## Steg $((n+1)) |^## Bonus/" README.md | grep -cE '^\*\*(Mål|Oppgave|Forventet resultat|Fasit)\*\*'); echo "steg $n: $c"; done`
Expected: `4` for hvert steg.

- [ ] **Step 4: Commit**

```bash
git add README.md .github/workflows/.gitkeep
git commit -m "Legg til workshop-README"
```

---

### Task 7: Sluttverifisering

**Files:**
- Create: `scripts/check-solutions.sh`

- [ ] **Step 1: Skriv sjekkeskriptet**

`scripts/check-solutions.sh` kjører `actionlint` på alle `.yml` under `solutions/`
(unntatt `dependabot.yml`, som ikke er en workflow), og feiler hvis en action refereres
uten versjon eller med en annen major enn listen i Global Constraints.

- [ ] **Step 2: Kjør full verifisering fra rent utgangspunkt**

```bash
rm -rf node_modules dist && npm ci && npm test && npm run build && bash scripts/check-solutions.sh
```
Expected: alle fire kommandoene exit 0.

- [ ] **Step 3: Bekreft at `.github/workflows/` er tom**

Run: `ls -A .github/workflows/`
Expected: kun `.gitkeep`.

- [ ] **Step 4: Bekreft at lockfilen er committet**

Run: `git ls-files package-lock.json`
Expected: `package-lock.json`.

- [ ] **Step 5: Commit**

```bash
git add scripts/check-solutions.sh
git commit -m "Legg til sjekkeskript for fasiten"
```
