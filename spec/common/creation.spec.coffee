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
    # TODO

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