# Fasit

Her ligger løsningsforslag for hvert steg.

Fila ligger **utenfor `.github/`** med vilje. Hadde de ligget i
`.github/workflows/`, ville GitHub kjørt alle sammen med én gang du forket —
og du ville aldri fått sett dem feile først.

## Hvor filene skal

| Fasitfil | Kopieres til |
|---|---|
| `steg-1/hello.yml` | `.github/workflows/hello.yml` |
| `steg-2/ci.yml` | `.github/workflows/ci.yml` |
| `steg-3/ci.yml` | `.github/workflows/ci.yml` *(erstatter steg 2)* |
| `steg-4/actions/setup-app/action.yml` | `.github/actions/setup-app/action.yml` |
| `steg-4/ci.yml` | `.github/workflows/ci.yml` *(erstatter steg 3)* |
| `steg-5/build.yml` | `.github/workflows/build.yml` |
| `steg-5/ci.yml` | `.github/workflows/ci.yml` *(erstatter steg 4)* |
| `steg-6/environments.yml` | `.github/workflows/environments.yml` |
| `steg-7/deploy.yml` | `.github/workflows/deploy.yml` |
| `bonus/dependabot.yml` | `.github/dependabot.yml` — **ikke** i `workflows/` |
| `bonus/*.yml` (resten) | `.github/workflows/` |

Legg merke til at `ci.yml` bygges videre på gjennom steg 2, 3, 4 og 5. Hvert
steg erstatter det forrige.

`steg-7/README.md` og `bonus/README.md` inneholder de stegene som er ren
klikking i GitHub-grensesnittet, og har ingen YAML.

## Bruk fasiten riktig

Prøv selv først, og slå opp når du står fast. Kommentarene i filene forklarer
*hvorfor* noe er som det er — det er den delen som er verdt å lese, også når du
fikk det til på egen hånd.

---

## For fasilitator

### Tidsbudsjett (~2 timer kjerne)

| Steg | Tid | Merknad |
|---|---|---|
| 0 — Oppsett | 10 min | Gå gjennom i plenum. Det er her folk henger seg opp. |
| 1 — Første workflow | 15 min | |
| 2 — Bygg og test | 20 min | |
| 3 — Permissions | 20 min | De må lage en PR. Sett av tid. |
| 4 — Composite action | 20 min | |
| 5 — Gjenbrukbar workflow | 20 min | **Hopp over dette først** hvis dere ligger bakpå. |
| 6 — Environments | 15 min | Mest klikking. |
| 7 — Deploy med gate | 20 min | Høydepunktet. Ikke la det ryke. |

Blir dere ferdige tidlig, er bonusstegene uavhengige av hverandre — la folk
velge selv.

### De to tingene som stopper folk

Begge hører hjemme i steg 0, og begge er verdt å si høyt i plenum:

1. **Forken må være public.** Deployment protection rules — altså hele steg 7 —
   finnes ikke på private repoer med gratiskonto. Oppdager noen dette først i
   steg 7, har de gjort seks steg forgjeves på feil premiss.

2. **Actions er deaktivert i nye forks.** Deltakeren må inn på Actions-fanen og
   trykke «I understand my workflows, go ahead and enable them». Uten dette
   skjer det *ingenting* når de pusher, og det gir ingen feilmelding — det er
   bare stille. Erfaringsmessig den vanligste grunnen til at noen rekker opp
   hånda i steg 1.

### Vanlige spørsmål

**«Workflowen min dukker ikke opp i Actions-fanen.»**
Fila må ligge i `.github/workflows/`, ha endelsen `.yml` eller `.yaml`, og være
pushet til default-branchen. For `workflow_dispatch` gjelder dessuten at knappen
bare vises når workflowen finnes på default-branchen.

**«Hvorfor kjører ikke jobben min på pull requesten?»**
Sjekk `if:`-betingelsen og hvilke triggere `on:` har. En PR fra en branch i
samme repo gir både `push` og `pull_request` — det overrasker mange.

**«Gaten dukker ikke opp.»**
Public fork, og protection rule lagret med «Save protection rules». Begge deler.

### Vedlikehold

`scripts/check-solutions.sh` kjører `actionlint` over alle workflowene i
fasiten og sjekker at action-versjonene stemmer med det som er dokumentert.
Kjør den før du deler workshopen ut på nytt — action-majorversjoner endrer seg
raskere enn man tror.
