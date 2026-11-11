import { greet } from './greeting'
import { resolveGreeting } from './config'

const greeting = resolveGreeting(import.meta.env)

const app = document.querySelector<HTMLDivElement>('#app')
if (app) {
  app.innerHTML = `
    <h1>${greet('verden', greeting)}</h1>
    <p class="hint">
      Teksten over styres av miljøvariabelen <code>VITE_APP_GREETING</code>
      på byggetidspunktet. Lokalt er den ikke satt, så du ser fallback-verdien.
      I steg 6 og 7 setter du den som en environment-variabel i GitHub.
    </p>
  `
}
