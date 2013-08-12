c = require '../../src/common/character'
bt = require '../../src/common/basetypes'

describe 'Character', ->
  char = null

  beforeEach ->
    char = new c.Character
    char.setMetatype 'human'

  expectAttribute = (attr, value = undefined) ->
    expect(char.attributes[attr]).toBeDefined()
    expect(char.attributes[attr].value).toBeDefined()
    if value?
      expect(char.attributes[attr].value.value).toBe value

  it 'comes with the basic attributes', ->
    for attr in ['bod', 'agi', 'rea', 'str', 'wil', 'log', 'int', 'cha', 'ess', 'edg']
      expect(char.attributes[attr]).toBeDefined()
      expect(char.attributes[attr].value).toBeDefined()

  it 'starts out with essence 6', ->
    expect(char.attributes.ess.value.value).toBe 6

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

    it 'sets the maximum magic to 6', ->
      char.setMagicType 'magician'
      expect(char.attributes.mag.max.value).toBe 6

    it 'reducing essence by 0.1 reduces the maximum magic by 1', ->
      char.setMagicType 'magician'
      char.attributes.ess.value.addEffect new bt.ModValue -0.1
      expect(char.attributes.mag.max.value).toBe 5

    it 'reducing essence by 1.0 reduces the maximum magic by 1', ->
      char.setMagicType 'magician'
      char.attributes.ess.value.addEffect new bt.ModValue -1.0
      expect(char.attributes.mag.max.value).toBe 5

    it 'reducing essence by 1.1 reduces the maximum magic by 2', ->
      char.setMagicType 'magician'
      char.attributes.ess.value.addEffect new bt.ModValue -1.1
      expect(char.attributes.mag.max.value).toBe 4

    it 'reducing essence by 0.1 reduces the actual magic by 1', ->
      char.setMagicType 'magician'
      char.attributes.mag.value.addEffect new bt.ModValue 2
      char.attributes.ess.value.addEffect new bt.ModValue -0.1
      expect(char.attributes.mag.value.value).toBe 1

    describe 'Types', ->

      it 'allows adepts to purchase powers', ->
        char.setMagicType 'adept'
        expect(char.canUseAdeptPowers()).toBe true

  describe 'Resonance', ->
    it 'does not allow wrong resonance type to be set', ->
      expect(-> char.setResonanceType 'frobnicator').toThrow()

    it 'gives resonance to a technomancer', ->
      char.setResonanceType 'technomancer'
      expectAttribute 'res', 0
