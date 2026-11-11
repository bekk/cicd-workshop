/**
 * Setter sammen en hilsen. Tomt navn faller tilbake til "verden",
 * slik at siden aldri viser "Hei, !".
 */
export function greet(name: string, greeting: string): string {
  const trimmed = name.trim()
  return `${greeting}, ${trimmed === '' ? 'verden' : trimmed}!`
}
