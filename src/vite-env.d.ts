/// <reference types="vite/client" />

// Deklarerer miljøvariabelen vår, slik at TypeScript kjenner den igjen.
// Uten dette vet ikke tsc at import.meta.env.VITE_APP_GREETING finnes.
interface ImportMetaEnv {
  readonly VITE_APP_GREETING?: string
}
