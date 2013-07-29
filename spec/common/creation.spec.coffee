cr = require '../../src/common/creation'

describe 'Priority Creation', ->
  c = null

  beforeEach ->
    c = new cr.Creation

  it 'starts out with an empty char', ->
    expect(c.char).toBeDefined()
    expect(c.char.name).toBe null
    expect(c.char.attributes.bod).toBeDefined()
    expect(c.char.attributes.bod.value.value).toBe null

  describe 'Metatype', ->
    it 'does not give special attributes to unknown metatypes', ->
      c.setPriority 'metatype', 'B'
      expect(c.points.specialAttributes.available).toBeUndefined()

    it 'gives 7 special attributes to human on B', ->
      c.setMetatype 'human'
      c.setPriority 'metatype', 'B'
      expect(c.points.specialAttributes.available).toBe 7

  describe 'Attributes', ->
    it 'does not give attribute points without priority', ->
      expect(c.points.attributes.available).toBe 0

    it 'gives 20 attribute points on priority B', ->
      c.setPriority 'attributes', 'B'
      expect(c.points.attributes.available).toBe 20

  describe 'Magic', ->
    beforeEach ->
      c = new cr.Creation
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

  describe 'Resonance', ->
# TODO implement resonance
#    it 'gives 4 resonance when selecting technomancer on priority B', ->
#      c.setResonanceType 'technomancer'
#      expect(c.char.attributes.res.value.value).toBe 4

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
      c = new cr.Creation
      c.applyState state

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