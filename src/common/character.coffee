#= require ./data/core
#= require ./basetypes
core = @core ? require('./data/core')
basetypes = @basetypes ? require('./basetypes')

copy = (obj) ->
  if Array.isArray(obj)
    result = (copy(e) for e in obj)
  else if typeof obj == 'object'
    result = {}
    for own key, value of obj
      result[key] = copy(value)
  else
    result = obj
  return result

class Metatype extends basetypes.EffectsProvider
  constructor: (@name, target) ->
    super(target)
    @data = copy(core.metatype[@name])
    for attr, limit of @data.attributes
      @effects["attributes.#{attr}.min"] = new basetypes.InitialValue limit.min
      @effects["attributes.#{attr}.max"] = new basetypes.InitialValue limit.max
      @effects["attributes.#{attr}.value"] = new basetypes.InitialValue limit.min
    @effects['attributes.ess.max'] = new basetypes.InitialValue 6
    @effects['attributes.ess.value'] = new basetypes.InitialValue 6
    return

class Attribute
  constructor: ->
    @min = new basetypes.Value
    @max = new basetypes.Value
    @value = new basetypes.Value

class Attributes extends basetypes.EffectTarget
  constructor: ->
    super
    for attr in core.attributes.universal
      @addAttribute attr

  addAttribute: (attr) ->
    @[attr] = new Attribute

  removeAttribute: (attr) ->
    delete @[attr]

class AddAttributeEffect extends basetypes.Effect
  constructor: (@attr) ->

  apply: (attributes) ->
    attributes.addAttribute @attr

  unApply: (attributes) ->
    attributes.removeAttribute @attr

class MagicType extends basetypes.EffectsProvider
  @magicTypes = {}
  @registerMagicType: (subtype) ->
    @magicTypes[subtype.magicType] = subtype
  @get: (name, target) ->
    return null if not name
    namedType = @magicTypes[name]
    if not namedType
      throw new Error "No MagicType named #{name} found!"
    return new namedType target

  constructor: (target) ->
    super target
    @name = @.constructor.magicType
    @effects['attributes'] = new AddAttributeEffect('mag')
    @effects['attributes.mag.min'] = new basetypes.InitialValue 0
    @effects['attributes.mag.max'] = new basetypes.InitialValue 6
    # TODO: make this reflect essence
    @effects['attributes.mag.value'] = new basetypes.InitialValue 0

  canUseAdeptPowers: -> false

class Adept extends MagicType
  @magicType = 'adept'
  MagicType.registerMagicType(@)
  constructor: (target) ->
    super target
  canUseAdeptPowers: -> true

class Magician extends MagicType
  @magicType = 'magician'
  MagicType.registerMagicType(@)
  constructor: (target) ->
    super target

class AspectedMagician extends MagicType
  @magicType = 'aspectedMagician'
  MagicType.registerMagicType(@)
  constructor: (target) ->
    super target

class MysticAdept extends MagicType
  @magicType = 'mysticAdept'
  MagicType.registerMagicType(@)
  constructor: (target) ->
    super target
  canUseAdeptPowers: -> true

class ResonanceType extends basetypes.EffectsProvider
  @resonanceTypes = {}
  @registerResonanceType: (subtype) ->
    @resonanceTypes[subtype.resonanceType] = subtype
  @get: (name, target) ->
    return null if not name
    namedType = @resonanceTypes[name]
    return new namedType target

  constructor: (target) ->
    super target
    @name = @.constructor.resonanceType
    @effects['attributes'] = new AddAttributeEffect('res')
    @effects['attributes.res.min'] = new basetypes.InitialValue 0
    @effects['attributes.res.max'] = new basetypes.InitialValue 6
    # TODO: make this reflect essence
    @effects['attributes.res.value'] = new basetypes.InitialValue 0

class Technomancer extends ResonanceType
  @resonanceType = 'technomancer'
  ResonanceType.registerResonanceType(@)
  constructor: (target) ->
    super target

class Character
  constructor: ->
    @name = null
    @metatype = null
    @magicType = null
    @resonanceType = null
    @attributes = new Attributes
    @effectsProviders = []

  setMetatype: (metatype) ->
    newMetaType = new Metatype metatype, @
    @metatype?.unApplyEffects()
    @metatype = newMetaType
    @metatype.applyEffects()

  setMagicType: (magicType) ->
    newMagicType = MagicType.get magicType, @
    @magicType?.unApplyEffects()
    @magicType = newMagicType
    @magicType?.applyEffects()

  setResonanceType: (resonanceType) ->
    newResonanceType = ResonanceType.get resonanceType, @
    @resonanceType?.unApplyEffects()
    @resonanceType = newResonanceType
    @resonanceType?.applyEffects()

  addEffectsProvider: (effectsProvider) ->
    if effectsProvider.target() != @
      throw new Error "EffectsProvider #{effectsProvider} does not apply to character, but to #{effectsProvider.target()}!"
    effectsProvider.applyEffects()
    @effectsProviders.push effectsProvider

  removeEffectsProvider: (effectsProvider) ->
    index = @effectsProviders.indexOf effectsProvider
    throw new Error "EffectProvider #{effectsProvider} is not in list!" if index == -1
    effectsProvider.unApplyEffects()
    @effectsProviders.splice index, 1

  canUseAdeptPowers: () ->
    @magicType? && @magicType.canUseAdeptPowers @

class CharacterModifier
  notImplemented = ->
    throw new Error "this method is not implemented"

  increaseAttribute: notImplemented
  canIncreaseAttribute: notImplemented
  decreaseAttribute: notImplemented
  canDecreaseAttribute: notImplemented

  attributeValueValid: notImplemented


do (exports = exports ? @character = {}) ->
  exports.Metatype = Metatype
  exports.Attribute = Attribute
  exports.Attributes = Attributes
  exports.Character = Character
  exports.CharacterModifier = CharacterModifier
  exports.MagicType = MagicType
  exports.ResonanceType = ResonanceType
