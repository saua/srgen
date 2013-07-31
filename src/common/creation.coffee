#= require ./character
#= require ./data/core
#= require ./basetypes
character = @character ? require './character'
core = @core ? require './data/core'
basetypes = @basetypes ? require './basetypes'

cp = core.creation.priority

class CreationModifier extends character.CharacterModifier
  constructor: (creation) ->
    @creation = -> creation

  getAttribute: (attrName) ->
    @creation().char.attributes[attrName]

  modAttribute: (attrName, modValue) ->
    attrPath = "attributes.#{attrName}.value"
    creation = @creation()
    effect = creation.effects.get attrPath
    if effect
      effect.mod += modValue
      creation.effects.reApplyEffects()
    else
      creation.effects.add attrPath, new basetypes.ModValue modValue
    creation.points.attributes.used += modValue

  decreaseAttribute: (attrName) ->
    throw "Can't decrease #{attrName}!" if not @canDecreaseAttribute attrName
    @modAttribute attrName, -1

  increaseAttribute: (attrName) ->
    throw "Can't increase #{attrName}!" if not @canIncreaseAttribute attrName
    @modAttribute attrName, +1

  canDecreaseAttribute: (attrName) ->
    attr = @getAttribute attrName
    return attr.value.value > attr.min.value

  canIncreaseAttribute: (attrName) ->
    attr = @getAttribute attrName
    return attr.value.value < attr.max.value

  attributeValueValid: (attrName) ->
    return true if not attrName?
    attr = @getAttribute attrName
    return attr.min.value <= attr.value.value <= attr.max.value


class CreationEffects extends basetypes.EffectsProvider
  constructor: (creation) ->
    super creation.char

  add: (path, effect) ->
    @unApplyEffects()
    @effects[path] = effect
    @applyEffects()

  get: (path) ->
    @effects[path]

class Creation
  constructor: ->
    @char = new character.Character
    @effects = new CreationEffects @
    @char.addEffectsProvider @effects
    @priority =
      metatype: null
      attributes: null
      magic: null
      skills: null
      resources: null
    defaultPoints = -> available: 0, used: 0
    @points =
      attributes: defaultPoints()
      specialAttributes: defaultPoints()
      skills: defaultPoints()
      skillGroups: defaultPoints()
      resources: defaultPoints()
      karma: available: 25, used: 0
    @metatype = null
    @modifier = new CreationModifier @

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

  setMagicType: (magicType) ->
    @char.setMagicType magicType || null
    @applyPriorities()

  setResonanceType: (resonanceType) ->
    @char.setResonanceType resonanceType || null
    @applyPriorities()

  applyPriorities: () ->
    getAspectPriority = (aspect) => cp.aspect[aspect][@priority[aspect]]

    metatype = getAspectPriority 'metatype'
    if metatype?
      @points.specialAttributes.available = metatype[@metatype]

    attributes = getAspectPriority 'attributes'
    if attributes?
      @points.attributes.available = attributes

    magic = getAspectPriority 'magic'
    if magic?
      if @char.magicType?
        specificMagicAspect = magic[@char.magicType.name]
        if specificMagicAspect
          @char.magicType.effects['attributes.mag.value'] = new basetypes.InitialValue specificMagicAspect.mag
          @char.magicType.applyEffects @char
      if @char.resonanceType?
        specificResonanceAspect = magic[@char.resonanceType.name]
        if specificResonanceAspect
          @char.resonanceType.effects['attributes.res.value'] = new basetypes.InitialValue specificResonanceAspect.res
          @char.resonanceType.applyEffects @char

    skills = getAspectPriority 'skills'
    if skills?
      @points.skills.available = skills.skills
      @points.skillGroups.available = skills.skillGroups

    resources = getAspectPriority 'resources'
    if resources?
      @points.resources.available = resources

  exportState: () ->
    priority: @priority
    metatype: @metatype
    name: @char.name
    magicType: @char.magicType?.name || null
    resonanceType: @char.resonanceType?.name || null


  applyState: (state) ->
    @setMetatype state.metatype if state.metatype
    for aspect, prio of state.priority
      @setPriority aspect, prio if prio
    @setMagicType state.magicType
    @setResonanceType state.resonanceType
    @char.name = state.name

do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation