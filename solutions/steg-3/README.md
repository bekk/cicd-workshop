# Fasit for steg 3 — oppsettet i Settings

`ci.yml` i denne mappa er bare halve svaret. Resten er klikking.

## 1. Skru på Pages

**Settings → Pages → Build and deployment → Source: `GitHub Actions`**

Ikke velg "Deploy from a branch". Det er den gamle måten, og da ignoreres
workflowen din fullstendig.

Når du har gjort dette, lager GitHub automatisk et environment som heter
`github-pages`. Under **Settings → Environments → `github-pages` → Deployment
branches and tags** ser du at bare `main` får deploye dit. Det er derfor
deploy-jobben bare kjører på `main`.

## 2. Sett variabelen

**Settings → Secrets and variables → Actions → Variables → New repository variable**

```
APP_GREETING = Hei fra GitHub Pages
```

Hvorfor på repoet, og ikke på `github-pages`-environmentet? Fordi appen bygges
i byggejobben, og den kjører ikke i noe environment. Environment-variabler er
bare synlige for jobber som kjører i det environmentet. En repo-variabel ser
alle jobber.

Hopper du over dette, blir `vars.APP_GREETING` en tom streng, og appen faller
tilbake til `Hei fra localhost`. Det er ikke en feil — det er fallbacken i
`src/config.ts` som gjør jobben sin.

## 3. Push til main

Kjøringen får to jobber: `build`, og `deploy` som starter når bygget er ferdig.
Deploy-jobben får en URL. Klikk på den og se at hilsenen din står der.

Pusher du til en annen branch, eller åpner en pull request, hoppes
deploy-jobben over. Bare `main` deployes.
