/**
 * Hilsenen settes av miljøvariabelen VITE_APP_GREETING på byggetidspunktet.
 * I workshopen kommer verdien fra en environment-variabel i GitHub (steg 5 og 6).
 * Lokalt er den ikke satt, og da brukes fallback-teksten.
 */
export const FALLBACK_GREETING = 'Hei fra localhost'

export function resolveGreeting(env: { VITE_APP_GREETING?: string }): string {
  const fromEnv = env.VITE_APP_GREETING?.trim()
  return fromEnv ? fromEnv : FALLBACK_GREETING
}
