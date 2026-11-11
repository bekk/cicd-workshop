import { describe, expect, it } from 'vitest'
import { greet } from './greeting'
import { resolveGreeting } from './config'

describe('greet', () => {
  it('setter sammen hilsen og navn', () => {
    expect(greet('Ada', 'Hei')).toBe('Hei, Ada!')
  })

  it('trimmer whitespace rundt navnet', () => {
    expect(greet('  Ada  ', 'Hei')).toBe('Hei, Ada!')
  })

  it('faller tilbake til "verden" for tomt navn', () => {
    expect(greet('   ', 'Hei')).toBe('Hei, verden!')
  })
})

describe('resolveGreeting', () => {
  it('bruker VITE_APP_GREETING når den er satt', () => {
    expect(resolveGreeting({ VITE_APP_GREETING: 'Hallo fra prod' })).toBe('Hallo fra prod')
  })

  it('faller tilbake når variabelen mangler', () => {
    expect(resolveGreeting({})).toBe('Hei fra localhost')
  })

  it('faller tilbake når variabelen er tom', () => {
    expect(resolveGreeting({ VITE_APP_GREETING: '' })).toBe('Hei fra localhost')
  })
})
