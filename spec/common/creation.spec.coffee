cr = require '../../src/common/creation'

describe 'Creation', ->
  c = null

  beforeEach ->
    c = new cr.Creation

  it 'starts out with an empty char', ->
    expect(c.char).toBeDefined()
    expect(c.char.name).toBe null
    expect(c.char.attributes.bod).toBeDefined()
    expect(c.char.attributes.bod.value.value).toBe null