# Fasit

Her ligger løsningsforslag for hvert steg.

Filene ligger **utenfor `.github/`** med vilje. Hadde de ligget i
`.github/workflows/`, ville de dukket opp som ferdige workflows i forken din
med én gang du skrudde på Actions — og du ville fått svaret i fanget før du
hadde begynt.

## Hvor filene skal

| Fasitfil | Kopieres til |
|---|---|
| `steg-1/hello.yml` | `.github/workflows/hello.yml` |
| `steg-2/ci.yml` | `.github/workflows/ci.yml` |
| `steg-3/deploy.yml` | `.github/workflows/deploy.yml` |
| `steg-4/ci.yml` | `.github/workflows/ci.yml` *(erstatter steg 2)* |
| `steg-5/actions/setup-app/action.yml` | `.github/actions/setup-app/action.yml` |
| `steg-5/ci.yml` | `.github/workflows/ci.yml` *(erstatter steg 4)* |
| `steg-6/build.yml` | `.github/workflows/build.yml` |
| `steg-6/ci.yml` | `.github/workflows/ci.yml` *(erstatter steg 5)* |
| `steg-7/environments.yml` | `.github/workflows/environments.yml` |
| `bonus/dependabot.yml` | `.github/dependabot.yml` — **ikke** i `workflows/` |
| `bonus/*.yml` (resten) | `.github/workflows/` |

Legg merke til at `ci.yml` bygges videre på gjennom steg 2, 4, 5 og 6. Hvert
steg erstatter det forrige.

`steg-3/README.md` og `bonus/README.md` inneholder de stegene som er ren
klikking i GitHub-grensesnittet, og har ingen YAML.

## Bruk fasiten riktig

Prøv selv først, og slå opp når du står fast. Kommentarene i filene forklarer
*hvorfor* noe er som det er — det er den delen som er verdt å lese, også når du
fikk det til på egen hånd.
