# CI/CD-workshop

En workshop om GitHub Actions. Målet med workshopen er å bruke å bygge en pipeline som tester, bygger og deployer appen til GitHub Pages.

Denne README-en forteller *hva* du skal få til og *hva du skal se* når det
virker. Står du fast, ligger det et
løsningsforslag med forklaringer under [`solutions/`](solutions/).

---

## Steg 0 — Kom i gang

### Fork og klon repoet

Du trenger git. Med [GitHub CLI](https://cli.github.com) (`gh`) forker og
kloner du i én kommando:

```bash
gh repo fork bekk/cicd-workshop --clone
cd cicd-workshop
```

Uten `gh`: åpne [bekk/cicd-workshop](https://github.com/bekk/cicd-workshop),
trykk **Fork** øverst til høyre, og klon forken:

```bash
git clone https://github.com/<ditt-brukernavn>/cicd-workshop
cd cicd-workshop
```

### Kjør appen lokalt

Du trenger [Node](https://nodejs.org) **22.12 eller nyere** eller 24.

```bash
npm ci
npm run dev
```

Åpne adressen den skriver ut. Du skal se en hilsen og en setning om
`VITE_APP_GREETING`. 

Prøv også `npm test` og `npm run build`, så du vet hvordan de ser ut når de er
grønne. Det er de tre kommandoene pipelinen din skal kjøre.

---

## Steg 1 — Din første workflow


**Oppgave**

- Lag fila `.github/workflows/hello.yml`.
- Gi workflowen et navn, og la den trigges av både push til `main` og manuell
  kjøring fra Actions-fanen.
- Lag én jobb som kjører på en Ubuntu-runner.
- Legg inn to steg: ett som skriver ut hvem som startet kjøringen, og ett som
  kjører en kommando med `run`.
- Push, og finn kjøringen i Actions-fanen.

**Forventet resultat**

- Workflowen dukker opp i venstremenyen i Actions-fanen.
- Klikker du på workflowen i venstremenyen, finner du en **Run workflow**-knapp.
- Kjøringen er grønn, og du kan klikke deg inn i hvert enkelt steg og lese
  loggen.

**Hint** — Navnet som vises i menyen kommer fra `name` i fila, ikke fra filnavnet.
Trigges den ikke manuelt? Den knappen vises bare når workflowen finnes på
default-branchen. (altså at den har blitt merget til main)

**Les mer** · [Workflow-syntaks](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions) · [Triggere](https://docs.github.com/actions/reference/events-that-trigger-workflows) · [Kontekster](https://docs.github.com/actions/learn-github-actions/contexts) · [`run` med flere kommandoer](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstepsrun) · [Starter-workflows](https://github.com/actions/starter-workflows)

**Fasit** · [`solutions/steg-1/`](solutions/steg-1/)

---

## Steg 2 — Test appen



**Oppgave**

- Lag `.github/workflows/ci.yml` som trigges på push og på pull request.
- Hent koden inn på runneren. 
- Sett opp Node 24, og skru på caching av npm-avhengigheter.
- Kjør `npm ci` og `npm test` som egne steg.

**Forventet resultat**

- Grønn kjøring på fire steg, ferdig på under ett minutt.
- På kjøring nummer to er npm-installasjonen merkbart raskere. Caching virker.

**Tenk over** — Du skrev sannsynligvis `@v7` eller lignende bak action-navnene.
Hva betyr det egentlig? Hva er forskjellen på å skrive major-versjonen, en
nøyaktig versjon, og en full commit-SHA? Når spiller det en rolle?
Fasiten svarer på dette.

**Les mer** · [Finne og bruke actions](https://docs.github.com/actions/learn-github-actions/finding-and-customizing-actions) · [actions/setup-node](https://github.com/actions/setup-node)

**Fasit** · [`solutions/steg-2/`](solutions/steg-2/)

---

## Steg 3 — Deploy til GitHub Pages

**Mål** — Få appen live på en ekte URL hver gang du pusher til `main`.

**Oppgave**

1. Skru på Pages: **Settings → Pages → Source: GitHub Actions**. Da lager
   GitHub environmentet `github-pages`. Det er bare tilgjengelig for `main`, så
   det er bare `main` som kan deployes.
2. Lag en repository-variabel `APP_GREETING` med en hilsen du velger selv:
   **Settings → Secrets and variables → Actions → Variables**.
3. Utvid byggejobben i `ci.yml`: kjør `npm run build` med `APP_GREETING` sendt
   inn som miljøvariabelen `VITE_APP_GREETING`, og last så opp `dist/` med
   `actions/upload-pages-artifact`. Appen må bygges før den kan deployes.
4. Legg til en jobb som heter `deploy` i `ci.yml`. Den skal vente på
   byggejobben, bare kjøre på `main`, kjøre i environmentet `github-pages` og
   bruke `actions/deploy-pages`.
5. Gi deploy-jobben rettighetene den trenger med `permissions:`: `pages: write`
   for å publisere, og `id-token: write` for å be om et identitetstoken. Gi så
   få rettigheter som mulig, og bare til jobben som trenger dem — ikke til hele
   workflowen.
6. Push til `main`, og sjekk at siden virker.

**Forventet resultat**

- Kjøringen har to jobber: `build`, og `deploy`, som starter når bygget er ferdig.
- Deploy-jobben har en klikkbar URL i Actions-fanen. Siden viser hilsenen du
  satte i GitHub, ikke fallbacken fra koden.
- På andre brancher og på pull requests hoppes deploy-jobben over.

**Les mer** · [Pages med Actions](https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow) · [Variabler](https://docs.github.com/actions/how-tos/write-workflows/choose-what-workflows-do/use-variables) · [Permissions-syntaks](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions#permissions)

**Fasit** · [`solutions/steg-3/`](solutions/steg-3/)

---

## Steg 4 — Kommenter på pull requesten

**Oppgave**

- Utvid `ci.yml` med en jobb som skriver en kommentar på pull requesten når
  bygget er grønt. Bruk `gh pr comment`. `gh` er allerede installert på
  runneren.
- Jobben skal bare kjøre når hendelsen er en pull request, og den skal vente på
  at byggejobben er ferdig.
- `gh` trenger et token for å snakke med GitHub. Bruk `GITHUB_TOKEN`, som ligger
  klart i `secrets`. Tokenet må ha lov til å skrive på pull requests, så gi
  jobben rettigheten `pull-requests: write` med `permissions:`.
- Lag en branch, endre noe, og åpne en pull request mot `main` **i din egen fork**.

> [!WARNING]
> **Sjekk at pull requesten går til ditt eget repo.**
> GitHub foreslår automatisk en PR mot *original-repoet*. På PR-skjemaet: sett
> **base repository** til din egen fork før du oppretter.

**Forventet resultat**

- En grønn `comment`-jobb i kjøringen.
- En kommentar fra *github-actions (bot)* på pull requesten din.

**Hint** — `gh` leser tokenet fra miljøvariabelen `GH_TOKEN` og repoet fra
`GH_REPO`. Nummeret på pull requesten finner du i `github.event.number`.

**Les mer** · [GITHUB_TOKEN](https://docs.github.com/actions/security-for-github-actions/security-guides/automatic-token-authentication) · [Permissions-syntaks](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions#permissions) · [gh pr comment](https://cli.github.com/manual/gh_pr_comment)

**Fasit** · [`solutions/steg-4/`](solutions/steg-4/)

---

## Steg 5 — Din egen composite action



**Oppgave**

- Lag `.github/actions/setup-app/action.yml`. Mappenavnet er det du refererer
  til; filnavnet må være `action.yml`.
- Flytt Node-oppsettet og avhengighetsinstallasjonen inn i den.
- Gi actionen en input for Node-versjon, med en fornuftig standardverdi.
- Bruk actionen fra `ci.yml` i stedet for de to stegene du flyttet.

**Forventet resultat**

- `ci.yml` er merkbart kortere, og kjøringen gir nøyaktig samme resultat som før.
- I loggen ser du stegene fra actionen listet opp som vanlige steg.



**Les mer** · [Lage en composite action](https://docs.github.com/actions/tutorials/create-actions/create-a-composite-action) · [Metadata-syntaks](https://docs.github.com/actions/reference/metadata-syntax-for-github-actions)

**Fasit** · [`solutions/steg-5/`](solutions/steg-5/)

---

## Steg 6 — Gjenbrukbar workflow

> [!NOTE]
> Dette steget kan hoppes over hvis tiden er knapp.

**Mål** — Lage en hel workflow som kan kalles fra andre workflows.

**Oppgave**

- Lag `.github/workflows/build.yml` som ikke kan trigges direkte, men bare
  kalles av andre.
- Gi den en input for Node-versjon, og la den returnere antall tester som kjørte.
- La `ci.yml` kalle den i stedet for å ha byggestegene selv. Deploy-jobben
  skal fortsatt virke.
- La kommentarjobben fra steg 4 bruke tallet i kommentarteksten.

**Forventet resultat**

- I Actions-fanen vises den kalte workflowen som en egen, nøstet jobb du kan
  klikke deg inn i.
- Kommentaren på pull requesten inneholder antall tester.

**Hint** — To ting du ikke har sett før: et steg deler en verdi videre ved å
skrive `navn=verdi` til fila `$GITHUB_OUTPUT`, og for å få tak i den senere må
steget ha en `id`. Verdien må så løftes opp i to trinn — fra steg til jobb, og
fra jobb til workflow. For selve tallet: `vitest` kan skrive en JSON-rapport med
`--reporter=json --outputFile=...`, og `jq` finnes ferdig installert på runneren.

**Tenk over** — Du har nå laget to typer gjenbruk: en composite action i steg 5
og en gjenbrukbar workflow her. Hva er egentlig forskjellen, og når velger du
hva? Hint: hvor mange runnere er involvert, og hvem bestemmer rettighetene?

**Les mer** · [Gjenbrukbare workflows](https://docs.github.com/actions/how-tos/reuse-automations/reuse-workflows)

**Fasit** · [`solutions/steg-6/`](solutions/steg-6/)

---

## Bonus

Uavhengige av hverandre. Ta dem i den rekkefølgen du vil.

|        | Oppgave                                                                                                                                              |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **B1** | **Bruk din egen action fra et annet repo.** Tagg forken `v1` og referer actionen med full sti i stedet for `./`. Hva skjer med behovet for checkout? |
| **B2** | **Matrix.** Kjør testene på Node 22, 24 og 26, på både Linux og Windows. Sørg for at én feilende kombinasjon ikke avbryter de andre.                 |
| **B3** | **Caching.** Du skrudde på npm-caching i steg 2 med én linje. Gjør det samme manuelt, og se hva den ene linja egentlig gjorde.                       |
| **B4** | **Artifacts.** Last opp `dist/` fra byggejobben og ned igjen i en annen jobb. Hvorfor holder det ikke bare å skrive til disk?                        |
| **B5** | **Concurrency.** Få en ny push til å avbryte den forrige kjøringen på samme branch. Hva kan da skje med deploy-jobben i `ci.yml`?                    |
| **B6** | **Pinn til SHA.** Bytt alle action-referanser til full commit-SHA, og sett opp Dependabot til å holde dem oppdatert.                                 |

**Fasit** · [`solutions/bonus/`](solutions/bonus/)

---

## Når noe ikke virker

| Symptom                                      | Som regel                                                                               |
| -------------------------------------------- | --------------------------------------------------------------------------------------- |
| Ingenting skjer når jeg pusher               | Se Actions-fanen. Er det en gul «enable workflows»-boks der, trykk på den.              |
| Workflowen vises ikke i menyen               | Fila må ligge i `.github/workflows/`, hete `.yml`, og være pushet til default-branchen. |
| `Run workflow`-knappen mangler               | Workflowen må finnes på default-branchen for at manuell kjøring skal vises.             |
| `file not found` i et steg                   | Du har glemt å hente koden inn på runneren først.                                       |
| `Resource not accessible by integration`     | Manglende rettigheter. Se steg 4.                                                       |
| PR-en min kjører ingen sjekker               | PR-en gikk til original-repoet. Sjekk «base repository» på PR-en. Se steg 4.            |
| `Required property is missing: shell`        | Du er i en composite action. Se steg 5.                                                 |
| `… is not allowed to deploy to github-pages` | Deploy-jobben kjørte på en annen branch enn `main`. Se steg 3.                          |
| Siden er blank, konsollen sier 404 på assets | Bygget bruker absolutte stier. Se `vite.config.ts`.                                     |
