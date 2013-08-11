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

  add: (path, effect) ->
    @unApplyEffects()
    @effects[path] = effect
    @applyEffects()

  remove: (path, effect) ->
    if @effects[path] != effect
      throw new Error "Different effect #{@effects[path]} at #{path}, expected #{effect}!"
    @unApplyEffects()
    delete @effects[path]
    @applyEffects()

  get: (path) ->
    @effects[path]

  reset: ->
    @unApplyEffects()
    @effects.splice(0, @effects.length)

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
    @attributes  = {}
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
        @char.magicType.unApplyEffects()
        magicValue = specificMagicAspect?.mag || 0
        @char.magicType.effects['attributes.mag.value'] = new basetypes.InitialValue magicValue
        @char.magicType.applyEffects()
      if @char.resonanceType?
        specificResonanceAspect = magic[@char.resonanceType.name]
        @char.resonanceType.unApplyEffects()
        resonanceValue = specificResonanceAspect?.res || 0
        @char.resonanceType.effects['attributes.res.value'] = new basetypes.InitialValue resonanceValue
        @char.resonanceType.applyEffects()

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
    for name, value of @attributes
      @modAttribute name, value, true


  setMagicType: (magicType) ->
    if @char.magicType?.name == magicType
      return
    @char.setMagicType magicType || null
    if not magicType
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
    if not resonanceType
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
    attrPath = "attributes.#{attrName}.value"
    effect = @effects.get attrPath
    if effect
      if reset
        effect.mod = howMuch
      else
        effect.mod += howMuch
      @effects.reApplyEffects()
    else
      @effects.add attrPath, new basetypes.ModValue howMuch

    if not reset
      @attributes[attrName] = (@attributes[attrName] || 0) + howMuch

    if attrName in core.attributes.special
      @points.specialAttributes.used += howMuch
    else
      @points.attributes.used += howMuch

  removeAttributeMod: (attrName) ->
    attrPath = "attributes.#{attrName}.value"
    effect = @effects.get attrPath
    return if not effect
    @effects.remove attrPath, effect
    delete @attributes[attrName]
    if attrName in core.attributes.special
      @points.specialAttributes.used -= effect.mod
    else
      @points.attributes.used -= effect.mod


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
    attrPath = "attributes.#{attrName}.value"
    effect = @effects.get attrPath
    return effect? && effect.mod >= howMuch



  canIncreaseAttribute: (attrName, howMuch = 1) ->
    attr = @char.attributes[attrName]
    return attr? && attr.value.value+howMuch <= attr.max.value

  attributeValueValid: (attrName) ->
    return true if not attrName?
    attr = @char.attributes[attrName]
    return true if not attr?
    return attr.min.value <= attr.value.value <= attr.max.value

  exportState: () ->
    priority: @priority
    metatype: @metatype
    name: @char.name
    magicType: @char.magicType?.name || null
    resonanceType: @char.resonanceType?.name || null
    attributes: @attributes

  applyState = (that, state) ->
    that.setMetatype state.metatype if state.metatype
    for aspect, prio of state.priority
      that.setPriority aspect, prio if prio
    that.setMagicType state.magicType
    that.setResonanceType state.resonanceType
    that.char.name = state.name
    for name, value of state.attributes
      that.modAttribute name, value


do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation