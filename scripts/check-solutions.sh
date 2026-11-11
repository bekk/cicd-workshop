#!/usr/bin/env bash
# Vedlikeholdsverktøy for workshopen — ikke noe deltakerne trenger å kjøre.
#
# Sjekker at fasiten faktisk holder:
#   1. Alle workflows i solutions/ er gyldige (actionlint).
#   2. action.yml-filer parser og har de nøklene de må ha.
#   3. dependabot.yml parser.
#   4. Ingen action refereres uten versjon, og majorversjonene stemmer
#      med det som er dokumentert nedenfor.
#
# actionlint forstår bare workflows. action.yml og dependabot.yml har
# andre skjemaer og må sjekkes for seg — derfor tredelingen under.

set -uo pipefail
cd "$(dirname "$0")/.."

# Majorversjoner verifisert mot GitHub 2026-11-11.
# Oppdater denne lista når du bumper en action.
declare -a FORVENTET=(
  "actions/checkout@v7"
  "actions/setup-node@v7"
  "actions/upload-pages-artifact@v5"
  "actions/deploy-pages@v5"
  "actions/cache@v6"
  "actions/upload-artifact@v7"
  "actions/download-artifact@v8"
)

feil=0
melding() { printf '%s\n' "$1"; }

# --- 1. Workflows -----------------------------------------------------
# NB: mapfile finnes ikke i bash 3.2, som er det macOS leverer.
# Derfor den gammeldagse while-løkka.
workflows=()
while IFS= read -r linje; do workflows+=("$linje"); done < <(
  find solutions -name '*.yml' ! -name 'action.yml' ! -name 'dependabot.yml' | sort
)

if [ ${#workflows[@]} -eq 0 ]; then
  melding "FEIL: fant ingen workflows i solutions/"
  exit 1
fi

# Fasiten refererer ./.github/workflows/build.yml og ./.github/actions/...,
# som per design ikke finnes i DETTE repoet — de skal kopieres til
# deltakerens fork. actionlint kan derfor ikke slå dem opp, og den ene
# feilklassen ignoreres. Alt annet er fortsatt en ekte feil.
if actionlint -ignore 'could not read reusable workflow file' "${workflows[@]}"; then
  melding "OK   actionlint: ${#workflows[@]} workflows"
else
  melding "FEIL actionlint"
  feil=1
fi

# --- 2. action.yml ----------------------------------------------------
actions=()
while IFS= read -r linje; do actions+=("$linje"); done < <(
  find solutions -name 'action.yml' | sort
)
for f in "${actions[@]:-}"; do
  [ -n "$f" ] || continue
  if yq -e '.name and .description and .runs.using' "$f" >/dev/null 2>&1; then
    # Hvert run-steg i en composite action må ha shell satt.
    mangler=$(yq -r '[.runs.steps[] | select(.run) | select(has("shell") | not)] | length' "$f")
    if [ "$mangler" != "0" ]; then
      melding "FEIL $f: $mangler run-steg uten shell:"
      feil=1
    else
      melding "OK   $f"
    fi
  else
    melding "FEIL $f: mangler name, description eller runs.using"
    feil=1
  fi
done

# --- 3. dependabot.yml ------------------------------------------------
while IFS= read -r f; do
  if yq -e '.version == 2 and (.updates | length > 0)' "$f" >/dev/null 2>&1; then
    melding "OK   $f"
  else
    melding "FEIL $f: ugyldig dependabot-konfigurasjon"
    feil=1
  fi
done < <(find solutions -name 'dependabot.yml' | sort)

# --- 4. Action-versjoner ----------------------------------------------
# Plukk ut alle `uses: owner/repo@ref` (hopper over lokale ./-referanser).
brukt=()
while IFS= read -r linje; do brukt+=("$linje"); done < <(
  grep -rhoE 'uses:[[:space:]]+[a-zA-Z0-9_-]+/[a-zA-Z0-9_./-]+@[^[:space:]]+' solutions \
    | sed -E 's/uses:[[:space:]]+//' | sort -u
)

for ref in "${brukt[@]:-}"; do
  [ -n "$ref" ] || continue
  navn="${ref%@*}"
  versjon="${ref#*@}"
  # En full SHA er også gyldig — den brukes med vilje i bonus/README.md.
  if [[ "$versjon" =~ ^[0-9a-f]{40}$ ]]; then
    melding "OK   $navn pinnet til SHA"
    continue
  fi
  treff=0
  for f in "${FORVENTET[@]}"; do
    [ "$ref" = "$f" ] && treff=1 && break
  done
  if [ "$treff" = "1" ]; then
    melding "OK   $ref"
  else
    melding "FEIL $ref er ikke i den forventede versjonslista"
    feil=1
  fi
done

# Fang referanser uten versjon i det hele tatt.
# Mønsteret starter bevisst IKKE med punktum, så lokale ./-referanser
# (som med rette er uten versjon) ikke slår ut.
if grep -rnE 'uses:[[:space:]]+[a-zA-Z0-9_-]+/[a-zA-Z0-9_./-]+[[:space:]]*$' solutions; then
  melding "FEIL: action referert uten @versjon (se linjene over)"
  feil=1
fi

echo
if [ "$feil" = "0" ]; then
  echo "Alt grønt."
else
  echo "Noe feilet."
fi
exit "$feil"
