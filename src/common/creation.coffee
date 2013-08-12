#= require ./character
#= require ./data/core
#= require ./data/text
#= require ./basetypes
character = @character ? require './character'
core = @core ? require './data/core'
text = @text ? require './data/text'
basetypes = @basetypes ? require './basetypes'

cp = core.creation.priority

class CreationEffects extends basetypes.EffectsProvider
  constructor: (creation) ->
    super creation.char

  add: ->
    @unApplyEffects()
    super
    @applyEffects()

  remove: ->
    @unApplyEffects()
    super
    @applyEffects()

class Creation extends character.CharacterModifier
  constructor: (state = null) ->
    @char = new character.Character
    @effects = new CreationEffects @
    @char.addEffectsProvider @effects
    @priority =
      metatype: null
      attributes: null
      magic: null
      skills: null
      resources: null
    @attributeMods  = {}
    @attributeModEffects = {}
    defaultPoints = -> available: 0, used: 0
    @points =
      attributes: defaultPoints()
      specialAttributes: defaultPoints()
      skills: defaultPoints()
      skillGroups: defaultPoints()
      resources: defaultPoints()
      karma: available: 25, used: 0
    @metatype = null
    if state
      applyState @, state

  setMetatype: (name) ->
    @metatype = name
    @char.setMetatype name
    @applyPriorities()

  setPriority: (aspect, priority) ->
    throw new Error "Unknown aspect #{aspect}" unless aspect of @priority
    throw new Error "Invalid priority #{priority}" unless priority in cp.priorities
    return if @priority[aspect] == priority
    @priority[aspect] = priority
    @applyPriorities()

  getAspectPriority: (aspect) ->
    cp.aspect[aspect][@priority[aspect]]

  applyPriorities: () ->
    metatype = @getAspectPriority 'metatype'
    if metatype?
      @points.specialAttributes.available = metatype[@metatype]

    attributes = @getAspectPriority 'attributes'
    if attributes?
      @points.attributes.available = attributes

    magic = @getAspectPriority 'magic'
    if magic?
      if @char.magicType?
        specificMagicAspect = magic[@char.magicType.name]
        @char.magicType.setInitialMagic specificMagicAspect?.mag || 0
      if @char.resonanceType?
        specificResonanceAspect = magic[@char.resonanceType.name]
        @char.resonanceType.setInitialResonance specificResonanceAspect?.res || 0

    skills = @getAspectPriority 'skills'
    if skills?
      @points.skills.available = skills.skills
      @points.skillGroups.available = skills.skillGroups

    resources = @getAspectPriority 'resources'
    if resources?
      @points.resources.available = resources

    # re-apply point mods
    @points.attributes.used = 0
    @points.specialAttributes.used = 0
    for name, value of @attributeMods
      @modAttribute name, value, true

    @effects.reApplyEffects()


  setMagicType: (magicType) ->
    if @char.magicType?.name == magicType
      return
    @char.setMagicType magicType || null
    @removeAttributeMod 'pp'
    if not @char.magicType
      @removeAttributeMod 'mag'
    @applyPriorities()

  validateMagicType: ->
    result = []
    if @char.magicType
      magic = @getAspectPriority 'magic'
      if not (magic? and magic[@char.magicType.name]?)
        result.push text.error.invalidMagicType
    return result

  setResonanceType: (resonanceType) ->
    if @char.resonanceType?.name == resonanceType
      return
    @char.setResonanceType resonanceType || null
    if not @char.resonanceType
      @removeAttributeMod 'res'
    @applyPriorities()

  validateResonanceType: ->
    result = []
    if @char.resonanceType
      resonance = @getAspectPriority 'magic'
      if not (resonance? and resonance[@char.resonanceType.name]?)
        result.push text.error.invalidResonanceType
    return result

  modAttribute: (attrName, howMuch, reset = false) ->
    effect = @attributeModEffects[attrName]
    if effect
      if reset
        effect.mod = howMuch
      else
        effect.mod += howMuch
      @char.attributes[attrName].value.recalc()
    else
      effect = new basetypes.ModValue howMuch
      @attributeModEffects[attrName] = effect
      @effects.add "attributes.#{attrName}.value", effect

    @attributeMods[attrName] = effect.mod
    @applyAttributeCost attrName, howMuch

  applyAttributeCost: (attrName, howMuch) ->
    if attrName in core.attributes.special
      @points.specialAttributes.used += howMuch
    else if attrName in core.attributes.physicalMental
      @points.attributes.used += howMuch
    else if attr = 'pp'
      @points.karma.used += howMuch * 2


  removeAttributeMod: (attrName) ->
    effect = @attributeModEffects[attrName]
    return if not effect

    attrPath = "attributes.#{attrName}.value"
    @effects.remove attrPath, effect
    delete @attributeMods[attrName]
    delete @attributeModEffects[attrName]
    @applyAttributeCost attrName, -effect.mod


  decreaseAttribute: (attrName, howMuch = 1) ->
    throw "Can't decrease #{attrName} by #{howMuch}!" if not @canDecreaseAttribute attrName, howMuch
    @modAttribute attrName, -howMuch

  increaseAttribute: (attrName, howMuch = 1) ->
    throw "Can't increase #{attrName} by #{howMuch}!" if not @canIncreaseAttribute attrName, howMuch
    @modAttribute attrName, +howMuch

  canDecreaseAttribute: (attrName, howMuch = 1) ->
    attr = @char.attributes[attrName]
    if not (attr? && attr.value.value-howMuch >= attr.min.value)
      return false
    effect = @attributeModEffects[attrName]
    return effect? && effect.mod >= howMuch

  canIncreaseAttribute: (attrName, howMuch = 1) ->
    attr = @char.attributes[attrName]
    return attr? && attr.value.value+howMuch <= attr.max.value

  attributeValueValid: (attrName) ->
    return true if not attrName?
    attr = @char.attributes[attrName]
    return true if not attr?
    if attr.min? && attr.value.value < attr.min.value
      return false
    if attr.max? && attr.value.value > attr.max.value
      return false
    return true

  exportState: () ->
    priority: @priority
    metatype: @metatype
    name: @char.name
    magicType: @char.magicType?.name || null
    resonanceType: @char.resonanceType?.name || null
    attributeMods: @attributeMods

  applyState = (that, state) ->
    that.setMetatype state.metatype if state.metatype
    for aspect, prio of state.priority
      that.setPriority aspect, prio if prio
    that.setMagicType state.magicType
    that.setResonanceType state.resonanceType
    that.char.name = state.name
    for name, value of state.attributeMods
      that.modAttribute name, value


do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation