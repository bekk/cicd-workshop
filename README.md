# CI/CD-workshop

En workshop om GitHub Actions der du skriver alt selv.

Du starter med et repo som har en liten webapp og en **helt tom**
`.github/workflows/`-mappe. I løpet av sju steg bygger du opp en pipeline som
tester, bygger og deployer appen til GitHub Pages — med en godkjenning som må
klikkes før noe går live.

Denne README-en forteller *hva* du skal få til og *hva du skal se* når det
virker. Den gir deg ikke YAML-en. Den skriver du. Står du fast, ligger det et
løsningsforslag med forklaringer under [`solutions/`](solutions/).

**Tidsbruk:** drøye 2 timer for steg 1–7, pluss ti minutter på oppsettet. Bonusstegene tar så lang tid du har.

---

## Steg 0 — Kom i gang

### Fork repoet

Trykk **Fork** øverst til høyre.

> [!IMPORTANT]
> **Gjør forken public.**
> Steg 7 handler om å kreve godkjenning før et deploy. Den funksjonen —
> *deployment protection rules* — finnes ikke på private repoer med
> gratiskonto. Er forken privat, kommer du gjennom seks steg og stanger i det
> syvende.
>
> Er den allerede privat: Settings → General → Danger Zone → Change visibility.

### Skru på Actions

Gå innom **Actions**-fanen i forken din én gang.

Dukker det opp en gul boks med *«I understand my workflows, go ahead and enable
them»*, trykk på den. Som regel gjør den ikke det i denne workshopen: GitHub
deaktiverer bare workflows en fork *arver*, og dette repoet har med vilje en tom
`.github/workflows/`. Den første workflowen du skriver selv, kjører derfor med
én gang du pusher.

> [!NOTE]
> Skjer det likevel ingenting når du pusher i steg 1, er Actions-fanen det
> første stedet å se. Det er den eneste innstillingen som kan gjøre repoet helt
> stille uten å gi en feilmelding.

### Kjør appen lokalt

Du trenger [Node](https://nodejs.org) **22.12 eller nyere** — eller 24, som er
LTS. Node 23 og 25 er oddetallsversjoner uten langtidsstøtte, og avhengighetene
her støtter dem ikke. Du trenger også git.

```bash
git clone https://github.com/<ditt-brukernavn>/<ditt-forknavn>
cd <ditt-forknavn>
npm ci
npm run dev
```

Forken trenger ikke hete `cicd-workshop`. Appen er satt opp med relative stier
nettopp for at den skal virke uansett hva du kaller repoet ditt.

Åpne adressen den skriver ut. Du skal se en hilsen og en setning om
`VITE_APP_GREETING`. Den variabelen er den røde tråden gjennom workshopen: i
steg 6 setter du den i GitHub, og i steg 7 havner den på den deployede siden.

Prøv også `npm test` og `npm run build`, så du vet hvordan de ser ut når de er
grønne. Det er de tre kommandoene pipelinen din skal kjøre.

---

## Steg 1 — Din første workflow

**Mål** — Få en workflow til å kjøre, og bli kjent med hvor du ser resultatet.

**Oppgave**

- Lag fila `.github/workflows/hello.yml`.
- Gi workflowen et navn, og la den trigges av både push til `main` og manuell
  kjøring fra Actions-fanen.
- Lag én jobb som kjører på en Ubuntu-runner.
- Legg inn tre steg: ett som skriver ut hvem som startet kjøringen, ett som
  kjører flere kommandoer etter hverandre, og ett som bruker et annet shell enn
  standard.
- Push, og finn kjøringen i Actions-fanen.

**Forventet resultat**

- Workflowen dukker opp i venstremenyen i Actions-fanen.
- Det er en **Run workflow**-knapp du kan trykke på.
- Kjøringen er grønn, og du kan klikke deg inn i hvert enkelt steg og lese
  loggen.

**Hint** — Navnet som vises i menyen kommer fra `name` i fila, ikke fra filnavnet.
Trigges den ikke manuelt? Den knappen vises bare når workflowen finnes på
default-branchen.

**Les mer** · [Workflow-syntaks](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions) · [Triggere](https://docs.github.com/actions/reference/events-that-trigger-workflows)

**Fasit** · [`solutions/steg-1/`](solutions/steg-1/)

---

## Steg 2 — Bygg og test appen

**Mål** — Kjøre testene og bygget automatisk, med actions fra marketplace.

**Oppgave**

- Lag `.github/workflows/ci.yml` som trigges på push og på pull request.
- Hent koden inn på runneren. *Uten dette er mappa tom* — det er den vanligste
  nybegynnerfeilen.
- Sett opp Node 24, og skru på caching av npm-avhengigheter.
- Kjør `npm ci`, `npm test` og `npm run build` som egne steg.
- Når det er grønt: ødelegg en test i `src/greeting.test.ts` med vilje, push, og
  se hva som skjer.

**Forventet resultat**

- Grønn kjøring på fire–fem steg, ferdig på under ett minutt.
- Med en ødelagt test: rød kjøring, og testutskriften står i loggen under
  teststeget. Steget etter kjører ikke.
- På kjøring nummer to er npm-installasjonen merkbart raskere. Caching virker.

**Tenk over** — Du skrev sannsynligvis `@v7` eller lignende bak action-navnene.
Hva betyr det egentlig? Hva er forskjellen på å skrive major-versjonen, en
nøyaktig versjon, og en full commit-SHA? Når spiller det en rolle?
Fasiten svarer på dette.

**Les mer** · [Finne og bruke actions](https://docs.github.com/actions/learn-github-actions/finding-and-customizing-actions) · [actions/setup-node](https://github.com/actions/setup-node)

**Fasit** · [`solutions/steg-2/`](solutions/steg-2/)

---

## Steg 3 — Permissions

**Mål** — Forstå hva `GITHUB_TOKEN` har lov til, ved å ta rettighetene fra den først.

Dette steget er laget for å feile. Det er med vilje.

**Oppgave**

- Sett `contents: read` som rettighet på workflow-nivå i `ci.yml`, altså for
  hele fila. Gjør dette **først** — det er det som gjør resten av steget
  forutsigbart.
- Utvid `ci.yml` med en jobb som skriver en kommentar på pull requesten når
  bygget er grønt. Bruk `gh pr comment` — `gh` er allerede installert på
  runneren, og `GITHUB_TOKEN` ligger klart i `secrets`.
- Jobben skal bare kjøre når hendelsen faktisk er en pull request, og den skal
  vente på at byggejobben er ferdig.
- Lag en branch, endre noe, og åpne en pull request mot `main` **i din egen fork**.
- **Se jobben feile.** Les feilmeldingen før du går videre.
- Gi så jobben akkurat den rettigheten den mangler — ikke mer — og kjør på nytt.

> [!WARNING]
> **Sjekk at pull requesten går til ditt eget repo.**
> Når du pusher en branch til en fork, foreslår GitHub automatisk en PR mot
> *original-repoet*. Trykker du bare «Create pull request», havner den hos
> fasilitatoren — og da kjører det ingen sjekker, fordi det repoet har en tom
> `.github/workflows/`.
>
> På PR-skjemaet: sett **base repository** til din egen fork før du oppretter.

> [!NOTE]
> Hvorfor `contents: read` på workflow-nivå først? Fordi standardrettighetene
> varierer. Under Settings → Actions → General → Workflow permissions kan et
> repo stå på «Read and write permissions», og da ville kommentarjobben lyktes
> på første forsøk — og hele poenget med steget forsvant. Setter du
> `contents: read` øverst, får du 403 uansett hvordan forken din er satt opp.

**Forventet resultat**

- Første forsøk: rød jobb. Nederst i loggen for `comment`-steget står
  `GraphQL: Resource not accessible by integration (addComment)`. Det er 403-en
  — `gh` snakker GraphQL her, så den ser ikke ut som en vanlig HTTP-feil.
- Etter fiksen: grønn jobb, og en kommentar fra *github-actions (bot)* på pull
  requesten din.

**Tenk over** — Legg merke til at rettigheter på jobbnivå *erstatter*
workflow-nivået i stedet for å legge til. Skriver du bare
`pull-requests: write` på jobben, mister den lesetilgangen til koden som
workflow-nivået ga. Det overrasker de fleste første gang.

**Les mer** · [GITHUB_TOKEN](https://docs.github.com/actions/security-for-github-actions/security-guides/automatic-token-authentication) · [Permissions-syntaks](https://docs.github.com/actions/reference/workflow-syntax-for-github-actions#permissions)

**Fasit** · [`solutions/steg-3/`](solutions/steg-3/)

---

## Steg 4 — Din egen composite action

**Mål** — Pakke gjentatte steg inn i en action du kan gjenbruke.

**Oppgave**

- Lag `.github/actions/setup-app/action.yml`. Mappenavnet er det du refererer
  til; filnavnet må være `action.yml`.
- Flytt Node-oppsettet og avhengighetsinstallasjonen inn i den.
- Gi actionen en input for Node-versjon, med en fornuftig standardverdi.
- Bruk actionen fra `ci.yml` i stedet for de to stegene du flyttet.

**Forventet resultat**

- `ci.yml` er merkbart kortere, og kjøringen gir nøyaktig samme resultat som før.
- I loggen ser du stegene fra actionen listet opp som vanlige steg.

**To feller du nesten garantert går i**

1. Du får `Required property is missing: shell`. Composite actions har ingen
   standard for shell — hvert eneste kommandosteg må si det selv.
2. Du prøver å flytte checkout inn i actionen, og alt faller sammen. Tenk over
   hvorfor: hvor ligger fila GitHub må lese for å vite hva actionen gjør?

**Les mer** · [Lage en composite action](https://docs.github.com/actions/tutorials/create-actions/create-a-composite-action) · [Metadata-syntaks](https://docs.github.com/actions/reference/metadata-syntax-for-github-actions)

**Fasit** · [`solutions/steg-4/`](solutions/steg-4/)

---

## Steg 5 — Gjenbrukbar workflow

> [!NOTE]
> Dette steget kan hoppes over hvis tiden er knapp. Steg 6 og 7 bygger ikke på det.

**Mål** — Lage en hel workflow som kan kalles fra andre workflows.

**Oppgave**

- Lag `.github/workflows/build.yml` som ikke kan trigges direkte, men bare
  kalles av andre.
- Gi den en input for Node-versjon, og la den returnere antall tester som kjørte.
- La `ci.yml` kalle den i stedet for å ha byggestegene selv.
- La kommentarjobben fra steg 3 bruke tallet i kommentarteksten.

**Forventet resultat**

- I Actions-fanen vises den kalte workflowen som en egen, nøstet jobb du kan
  klikke deg inn i.
- Kommentaren på pull requesten inneholder antall tester.

**Hint** — To ting du ikke har sett før: et steg deler en verdi videre ved å
skrive `navn=verdi` til fila `$GITHUB_OUTPUT`, og for å få tak i den senere må
steget ha en `id`. Verdien må så løftes opp i to trinn — fra steg til jobb, og
fra jobb til workflow. For selve tallet: `vitest` kan skrive en JSON-rapport med
`--reporter=json --outputFile=...`, og `jq` finnes ferdig installert på runneren.

**Tenk over** — Du har nå laget to typer gjenbruk: en composite action i steg 4
og en gjenbrukbar workflow her. Hva er egentlig forskjellen, og når velger du
hva? Hint: hvor mange runnere er involvert, og hvem bestemmer rettighetene?

**Les mer** · [Gjenbrukbare workflows](https://docs.github.com/actions/how-tos/reuse-automations/reuse-workflows)

**Fasit** · [`solutions/steg-5/`](solutions/steg-5/)

---

## Steg 6 — Environments, variabler og secrets

**Mål** — La samme workflow oppføre seg ulikt avhengig av hvor den kjører.

**Oppgave**

- Lag to environments i **Settings → Environments**: `dev` og `prod`.
- Gi begge en *variabel* som heter `APP_GREETING`, men med forskjellig verdi.
- Gi begge en *secret* som heter `DEPLOY_TOKEN`, også med ulik verdi. Innholdet
  spiller ingen rolle.
- Lag `.github/workflows/environments.yml` som kan startes manuelt, der du velger
  environment fra en nedtrekksliste.
- La jobben skrive ut begge verdiene.
- Kjør den én gang mot `dev` og én gang mot `prod`.

**Forventet resultat**

- To kjøringer av nøyaktig samme fil, med forskjellig utskrift.
- Variabelen vises i klartekst i loggen.
- Secreten vises som `***`, uansett hva du prøver. Lengden kan du derimot måle —
  tenk over hva det betyr.
- Kjøringen er merket med hvilket environment den gikk mot.

**Les mer** · [Environments](https://docs.github.com/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments) · [Variabler](https://docs.github.com/actions/how-tos/write-workflows/choose-what-workflows-do/use-variables)

**Fasit** · [`solutions/steg-6/`](solutions/steg-6/)

---

## Steg 7 — Deploy med godkjenning

**Mål** — Få appen live på en ekte URL, bak en gate du må klikke på selv.

Dette er høydepunktet. Ta deg tid.

**Oppgave**

1. Skru på Pages: **Settings → Pages → Source: GitHub Actions**. Ikke «Deploy
   from a branch» — det er den gamle måten, og da ignoreres workflowen din.
2. Lag `.github/workflows/deploy.yml` som deployer `dist/` til Pages når du
   pusher til `main`. Du trenger `actions/upload-pages-artifact` og
   `actions/deploy-pages`, og jobben må kjøre i environmentet `github-pages`.
3. Gi jobben rettighetene den trenger. Den trenger to utover det vanlige — én
   for å skrive til Pages, og én for å be om et identitetstoken. Finn ut hvilke.
4. Send verdien fra `APP_GREETING` inn i bygget, slik at hilsenen på den
   deployede siden kommer fra GitHub og ikke fra fallbacken i koden.
   Variabelen må settes på `github-pages`-environmentet — verdiene fra `dev` og
   `prod` er ikke synlige her.
5. Kjør det én gang og sjekk at siden faktisk virker.
6. **Legg så på gaten:** Settings → Environments → `github-pages` →
   Deployment protection rules → **Required reviewers** → legg til deg selv → Save.
7. Push igjen.

**Forventet resultat**

- Første deploy: grønn kjøring, og en klikkbar URL på jobben i Actions-fanen.
  Siden viser hilsenen du satte i GitHub.
- Etter at gaten er på: kjøringen stopper med status **Waiting**, og det dukker
  opp en **Review deployments**-knapp. Ingenting deployes før du trykker.
- Du godkjenner din egen deploy, jobben fortsetter, og loggen viser hvem som
  godkjente og når.

**Tenk over** — Hvorfor heter environmentet `github-pages` og ikke `prod`? Og
hvorfor trenger deployet ingen secrets i det hele tatt? Fasiten forklarer begge
deler.

**Les mer** · [Pages med Actions](https://docs.github.com/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow) · [Deployment protection rules](https://docs.github.com/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments#deployment-protection-rules)

**Fasit** · [`solutions/steg-7/`](solutions/steg-7/)

---

## Bonus

Uavhengige av hverandre. Ta dem i den rekkefølgen du vil.

| | Oppgave |
|---|---|
| **B1** | **Bruk din egen action fra et annet repo.** Tagg forken `v1` og referer actionen med full sti i stedet for `./`. Hva skjer med behovet for checkout? |
| **B2** | **Matrix.** Kjør testene på Node 22, 24 og 26, på både Linux og Windows. Sørg for at én feilende kombinasjon ikke avbryter de andre. |
| **B3** | **Caching.** Du skrudde på npm-caching i steg 2 med én linje. Gjør det samme manuelt, og se hva den ene linja egentlig gjorde. |
| **B4** | **Artifacts.** Last opp `dist/` fra byggejobben og ned igjen i en annen jobb. Hvorfor holder det ikke bare å skrive til disk? |
| **B5** | **Concurrency.** Få en ny push til å avbryte den forrige kjøringen på samme branch. Hvorfor vil du *ikke* ha dette på deploy-workflowen? |
| **B6** | **Pinn til SHA.** Bytt alle action-referanser til full commit-SHA, og sett opp Dependabot til å holde dem oppdatert. |

**Fasit** · [`solutions/bonus/`](solutions/bonus/)

---

## Når noe ikke virker

| Symptom | Som regel |
|---|---|
| Ingenting skjer når jeg pusher | Se Actions-fanen. Er det en gul «enable workflows»-boks der, trykk på den. |
| Workflowen vises ikke i menyen | Fila må ligge i `.github/workflows/`, hete `.yml`, og være pushet til default-branchen. |
| `Run workflow`-knappen mangler | Workflowen må finnes på default-branchen for at manuell kjøring skal vises. |
| `file not found` i et steg | Du har glemt å hente koden inn på runneren først. |
| `Resource not accessible by integration` | Manglende rettigheter. Se steg 3. |
| PR-en min kjører ingen sjekker | PR-en gikk til original-repoet. Sjekk «base repository» på PR-en. Se steg 3. |
| Kommentarjobben ble grønn med én gang | Forken har «Read and write permissions» som standard. Sett `contents: read` på workflow-nivå. Se steg 3. |
| `Required property is missing: shell` | Du er i en composite action. Se steg 4. |
| Siden er blank, konsollen sier 404 på assets | Bygget bruker absolutte stier. Se `vite.config.ts`. |
| Required reviewers finnes ikke i menyen | Forken er privat. Se steg 0. |
