import { defineConfig } from 'vite'

export default defineConfig({
  // Relativ base gjør at bygget fungerer uansett hva du kaller forken din.
  // Med absolutt base ville assets peke på /cicd-workshop/... og gi 404
  // på https://<brukernavn>.github.io/<et-annet-navn>/.
  base: './',
})
