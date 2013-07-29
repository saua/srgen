c = require '../../src/common/character.coffee'

describe 'Character', ->
  char = null

  beforeEach ->
    char = new c.Character

  expectAttribute = (attr, value = undefined) ->
    expect(char.attributes[attr]).toBeDefined()
    expect(char.attributes[attr].value).toBeDefined()
    if value?
      expect(char.attributes[attr].value.value).toBe value

  it 'comes with the basic attributes', ->
    for attr in ['bod', 'agi', 'rea', 'str', 'wil', 'log', 'int', 'cha', 'ess', 'edg']
      expect(char.attributes[attr]).toBeDefined()
      expect(char.attributes[attr].value).toBeDefined()

  it 'does not come with magic by default', ->
    expect(char.attributes.mag).toBeUndefined()

  it 'does not come with resonance by default', ->
    expect(char.attributes.res).toBeUndefined()

  describe 'Magic', ->
    it 'does not allow wrong magic types to be set', ->
      expect(-> char.setMagicType 'clown').toThrow()

    it 'gives magic to a magician', ->
      char.setMagicType 'magician'
      expectAttribute 'mag', 0

    it 'gives magic to an adept', ->
      char.setMagicType 'adept'
      expectAttribute 'mag', 0

    it 'gives magic to an aspected magician', ->
      char.setMagicType 'aspectedMagician'
      expectAttribute 'mag', 0

