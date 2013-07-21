cr = require '../../src/common/creation'

describe 'Creation', ->
  cr = null

  beforeEach ->
    cr = new cr.Creation

  it 'starts out with an empty char', ->
    expect(cr.character).toBeDefined()
    expect(cr.character.name).toBe null
    expect(cr.char.attributes.bod).toBeDefined()
    expect(cr.character.attributes.bod.value).toBe Null