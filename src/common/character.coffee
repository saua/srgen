#= require ./data/core
#= require ./basetypes
core = @core ? require('./data/core')
basetypes = @basetypes ? require('./basetypes')

copy = (obj) ->
  if Array.isArray(obj)
    result = copy(e) for e in obj
  else if typeof obj == 'object'
    result = {}
    for own key, value of obj
      result[key] = copy(value)
  else
    result = obj
  return result

class Metatype extends basetypes.EffectsProvider
  constructor: (@name) ->
    super
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

class Attributes
  constructor: ->
    for attr in core.attributes.universal
      @addAttribute attr

  addAttribute: (attr) ->
    @[attr] = new Attribute

class Character
  constructor: ->
    @name = null
    @metatype = null
    @attributes = new Attributes

  setMetatype: (metatype) ->
    @metatype?.unApplyEffects(@)
    @metatype = new Metatype(metatype)
    @metatype.applyEffects(@)

do (exports = exports ? @char = {}) ->
  exports.Metatype = Metatype
  exports.Attribute = Attribute
  exports.Attributes = Attributes
  exports.Character = Character
