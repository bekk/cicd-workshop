# Fasit for steg 6 — oppsettet i Settings

`deploy.yml` i denne mappa er bare halve svaret. Resten er klikking, og den
rekkefølgen betyr noe.

## 1. Skru på Pages

**Settings → Pages → Build and deployment → Source: `GitHub Actions`**

Ikke velg "Deploy from a branch". Det er den gamle måten, og da ignoreres
workflowen din fullstendig.

Når du har gjort dette, lager GitHub automatisk et environment som heter
`github-pages`. Du ser det under Settings → Environments.

## 2. Sett variabelen

**Settings → Environments → `github-pages` → Environment variables → Add variable**

```
APP_GREETING = Hei fra GitHub Pages
```

Hvorfor her, når du allerede satte den på `dev` og `prod` i steg 5?
Fordi environment-variabler bare er synlige for jobber som faktisk kjører i
det environmentet. Deploy-jobben kjører i `github-pages`, og ser derfor
ingenting av det du la på `dev` eller `prod`.

Hopper du over dette, blir `vars.APP_GREETING` en tom streng, og appen faller
tilbake til `Hei fra localhost`. Det er ikke en feil — det er fallbacken i
`src/config.ts` som gjør jobben sin.

## 3. Kjør deployet én gang uten gate

Push til `main`, eller kjør workflowen manuelt. Den skal gå rett gjennom og
gi deg en URL. Klikk på den og se at hilsenen din står der.

Dette er verdt å gjøre før du legger på gaten, så du vet at deployet i seg
selv virker.

## 4. Legg på gaten

**Settings → Environments → `github-pages` → Deployment protection rules**

Huk av for **Required reviewers**, legg til deg selv, og trykk **Save protection rules**.

Mens du er her, se på de andre reglene:

- **Wait timer** — venter et gitt antall minutter før deployet starter. Nyttig
  når du vil ha en angrefrist.
- **Deployment branches** — begrenser hvilke brancher som får deploye til
  environmentet. I praksis det du vil ha på et prod-environment.

## 5. Kjør på nytt

Push igjen. Nå skjer det noe annet: kjøringen stopper med status **Waiting**,
og det dukker opp en **Review deployments**-knapp.

Trykk på den, huk av for `github-pages`, og **Approve and deploy**.

Jobben fortsetter der den slapp. Loggen viser hvem som godkjente og når — og
det er det som gjør dette til en revisjonsspor, ikke bare en pause.

> [!NOTE]
> Får du ikke opp **Required reviewers** i det hele tatt? Da er forken din
> privat. Deployment protection rules krever offentlig repo på gratiskontoer.
> Settings → General → Danger Zone → Change visibility.
