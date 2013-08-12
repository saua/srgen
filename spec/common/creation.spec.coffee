cr = require '../../src/common/creation'
bt = require '../../src/common/basetypes'

describe 'Priority Creation', ->
  c = null

  beforeEach ->
    c = new cr.Creation

  it 'starts out with an empty char', ->
    expect(c.char).toBeDefined()
    expect(c.char.name).toBe null
    expect(c.char.attributes.bod).toBeDefined()
    expect(c.char.attributes.bod.value.value).toBe null

  describe 'Attributes', ->
    beforeEach ->
      c.setMetatype 'human'

    it 'does not allow default attribute values to be decrease', ->
      expect(c.canDecreaseAttribute 'int').toBe false

    it 'allows default attribute values to be increase', ->
      expect(c.canIncreaseAttribute 'int').toBe true

    it 'increasing a attribute raises it', ->
      c.increaseAttribute 'int'
      expect(c.char.attributes.int.value.value).toBe 2

    it 'increasing a attribute twice raises it even further', ->
      c.increaseAttribute 'int'
      c.increaseAttribute 'int'
      expect(c.char.attributes.int.value.value).toBe 3

    it 'can not raise an attribute past its maximum', ->
      c.increaseAttribute 'int', 5
      expect(c.canIncreaseAttribute 'int').toBe false

    it 'can not raise an attribute past its maximum, all at once', ->
      expect(c.canIncreaseAttribute 'int', 6).toBe false

    it 'decreasing an increased attribute lowers it', ->
      c.increaseAttribute 'int'
      c.decreaseAttribute 'int'
      expect(c.char.attributes.int.value.value).toBe 1

    it 'increases used attribute points when increasing an attribute', ->
      attributePoints = c.points.attributes.used
      c.increaseAttribute 'int'
      expect(c.points.attributes.used).toBe attributePoints+1

    it 'resets used attribute points when decreasing an attribute', ->
      attributePoints = c.points.attributes.used
      c.increaseAttribute 'int'
      c.decreaseAttribute 'int'
      expect(c.points.attributes.used).toBe attributePoints

    it 'can not raise magic attribute without magic', ->
      expect(c.canIncreaseAttribute 'mag').toBe false

    it 'does not flag a failing maigc attribute as invalid', ->
      expect(c.attributeValueValid 'mag').toBe true

    it 'uses special attribute points to increase edge', ->
      c.increaseAttribute 'edg'
      expect(c.points.specialAttributes.used).toBe 1
      expect(c.points.attributes.used).toBe 0

    it 'does not allow magic to be increased without a magic type', ->
      expect(c.canIncreaseAttribute 'mag').toBe false

    it 'does not allow resonance to be increased without a resonance type', ->
      expect(c.canIncreaseAttribute 'res').toBe false

  describe 'Metatype', ->
    it 'does not give special attributes to unknown metatypes', ->
      c.setPriority 'metatype', 'B'
      expect(c.points.specialAttributes.available).toBeUndefined()

    it 'gives 7 special attributes to human on B', ->
      c.setMetatype 'human'
      c.setPriority 'metatype', 'B'
      expect(c.points.specialAttributes.available).toBe 7

    it 'gives new minimum values to non-humans', ->
      c.setMetatype 'dwarf'
      expect(c.char.attributes.bod.min.value).toBe 3
      expect(c.char.attributes.bod.value.value).toBe 3

    it 'adapts attribute values when switching metataype', ->
      c.setMetatype 'human'
      c.increaseAttribute 'bod'
      c.setMetatype 'dwarf'
      expect(c.char.attributes.bod.value.value).toBe 4

  describe 'Attributes', ->
    it 'does not give attribute points without priority', ->
      expect(c.points.attributes.available).toBe 0

    it 'gives 20 attribute points on priority B', ->
      c.setPriority 'attributes', 'B'
      expect(c.points.attributes.available).toBe 20

  describe 'Magic', ->
    beforeEach ->
      c = new cr.Creation
      c.setMetatype 'human'
      c.setPriority 'magic', 'B'

    it 'does not give magic or resonance without magic selection', ->
      expect(c.char.attributes.mag).toBeUndefined()
      expect(c.char.attributes.res).toBeUndefined()

    it 'gives 4 magic when selecting magician on priority B', ->
      c.setMagicType 'magician'
      expect(c.char.attributes.mag.value.value).toBe 4

    it 'gives 6 magic when selecting adept on priority B', ->
      c.setMagicType 'adept'
      expect(c.char.attributes.mag.value.value).toBe 6

    it 'gives 5 magic when selecting aspected magician on priority B', ->
      c.setMagicType 'aspectedMagician'
      expect(c.char.attributes.mag.value.value).toBe 5

    it 'gives 4 magic when selecting aspected magician on priority B and lowering essence by 0.1', ->
      c.setMagicType 'aspectedMagician'
      c.char.attributes.ess.value.addEffect new bt.ModValue -0.1
      expect(c.char.attributes.mag.value.value).toBe 4

    it 'does not allow magic to be lowered below the initial value', ->
      c.setMagicType 'aspectedMagician'
      expect(c.canDecreaseAttribute 'mag').toBe false
      expect(-> c.decreaseAttribute 'mag').toThrow()

    it 'remembers the attribute increase when switching magic type', ->
      c.setMagicType 'magician'
      c.increaseAttribute 'mag'
      c.setMagicType 'aspectedMagician'
      expect(c.char.attributes.mag.value.value).toBe 6

    it 'can take away magic', ->
      c.setMagicType 'magician'
      c.setMagicType null
      expect(c.char.attributes.mag).toBeUndefined()

    it 'resets the magic attribute when removing the magic type', ->
      c.setMagicType 'magician'
      origMagicValue = c.char.attributes.mag.value.value
      c.increaseAttribute 'mag'
      c.setMagicType null
      c.setMagicType 'magician'
      expect(c.char.attributes.mag.value.value).toBe origMagicValue
      expect(c.points.specialAttributes.used).toBe 0

    it 'does not reset magic attribute when switching between magic types', ->
      c.setMagicType 'magician'
      c.increaseAttribute 'mag'
      magicValue = c.char.attributes.mag.value.value
      c.setMagicType 'adept'
      c.setMagicType 'magician'
      expect(c.char.attributes.mag.value.value).toBe magicValue

    it 'reduces magic to 0 when reducing the magic priority below a required level', ->
      c.setMagicType 'magician'
      c.setPriority 'magic', 'D'
      expect(c.char.attributes.mag.value.value).toBe 0

    it 'reports the magic type as valid if the magic priority is high enough', ->
      c.setMagicType 'magician'
      expect(c.validateMagicType()).toEqual []

    it 'reports the magic type as invalid if the magic priority is not high enough', ->
      c.setMagicType 'magician'
      c.setPriority 'magic', 'D'
      expect(c.validateMagicType()).not.toEqual []

    it 'can take away power points', ->
      c.setMagicType 'adept'
      c.setMagicType null
      expect(c.char.attributes.pp).toBeUndefined()

    it 'gives 0 powerpoints when selecting mystic adept on priority B', ->
      c.setMagicType 'mysticAdept'
      expect(c.char.attributes.pp.value.value).toBe 0

    it 'allows powerpoints to be purchased for mystic adepts', ->
      c.setMagicType 'mysticAdept'
      c.increaseAttribute 'pp'
      expect(c.char.attributes.pp.value.value).toBe 1
      expect(c.points.karma.used).toBe 2

    it 'resets powerpoints mods when switching away from mystic adept', ->
      c.setMagicType 'mysticAdept'
      c.increaseAttribute 'pp'
      c.setMagicType 'adept'
      expect(c.char.attributes.pp.value.value).toBe 6
      expect(c.points.karma.used).toBe 0
      c.setMagicType 'mysticAdept'
      expect(c.char.attributes.pp.value.value).toBe 0

    it 'gives 6 powerpoints when selecting adept on priority B', ->
      c.setMagicType 'adept'
      expect(c.char.attributes.pp.value.value).toBe 6

  describe 'Resonance', ->
    beforeEach ->
      c = new cr.Creation
      c.setMetatype 'human'
      c.setPriority 'magic', 'B'

    it 'gives 4 resonance when selecting technomancer on priority B', ->
      c.setResonanceType 'technomancer'
      expect(c.char.attributes.res.value.value).toBe 4

    it 'resets the resonance attribute when removing the resonance type', ->
      c.setResonanceType 'technomancer'
      origResonanceValue = c.char.attributes.res.value.value
      c.increaseAttribute 'res'
      c.setResonanceType null
      c.setResonanceType 'technomancer'
      expect(c.char.attributes.res.value.value).toBe origResonanceValue
      expect(c.points.specialAttributes.used).toBe 0

    it 'reduces resonance to 0 when reducing the resonance/magic priority below a required level', ->
      c.setResonanceType 'technomancer'
      c.setPriority 'magic', 'D'
      expect(c.char.attributes.res.value.value).toBe 0

    it 'reports the resonance type as valid if the magic priority is high enough', ->
      c.setResonanceType 'technomancer'
      expect(c.validateResonanceType()).toEqual []

    it 'reports the resonance type as invalid if the magic priority is not high enough', ->
      c.setResonanceType 'technomancer'
      c.setPriority 'magic', 'D'
      expect(c.validateResonanceType()).not.toEqual []

  describe 'Skills', ->
    it 'does not give skill points without priority', ->
      expect(c.points.skills.available).toBe 0
      expect(c.points.skillGroups.available).toBe 0

    it 'gives 36/5 points for skills/skill groups on priority B', ->
      c.setPriority 'skills', 'B'
      expect(c.points.skills.available).toBe 36
      expect(c.points.skillGroups.available).toBe 5

  describe 'Resources', ->
    it 'does not give resources without priority', ->
      expect(c.points.resources.available).toBe 0

    it 'gives 275k Nuyen on priority B', ->
      c.setPriority 'resources', 'B'
      expect(c.points.resources.available).toBe 275000

  describe 'State Handling', ->
    reloadState = ->
      state = c.exportState()
      c = new cr.Creation state

    it 'can handle the initial state', ->
      reloadState()
      expect(c.metatype).toBe null

    it 'remembers the name in the state', ->
      c.char.name = 'Doe'
      reloadState()
      expect(c.char.name).toBe 'Doe'

    it 'remembers partial priorities', ->
      c.setPriority('skills', 'A')
      reloadState()
      expect(c.priority.skills).toBe 'A'
      expect(c.priority.magic).toBe null

    it 'remembers the metatype', ->
      c.setMetatype 'human'
      reloadState()
      expect(c.metatype).toBe 'human'

    it 'remembers the magicType', ->
      c.setMagicType 'adept'
      reloadState()
      expect(c.char.magicType.name).toBe 'adept'

    it 'remembers the resonanceType', ->
      c.setResonanceType 'technomancer'
      reloadState()
      expect(c.char.resonanceType.name).toBe 'technomancer'

    it 'remembers attribute points', ->
      c.setMetatype 'human'
      c.increaseAttribute 'int'
      reloadState()
      expect(c.char.attributes.int.value.value).toBe 2
