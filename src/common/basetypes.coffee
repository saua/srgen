# a very primitive jsonPath implementation, capable of only what I needed. Not tested for anything else
# specifically, this can only ever return a single object
# the advantage is that it always returns exactly the matched object and not a copy of it

# just to catch any fault use of require() in the client or common code
@require ?= -> throw Error 'require can not be used on the client side'

getPath = (obj, path) ->
  segments = path.split '.'
  result = obj
  for s in segments
    result = result[s]
  result

class Effect
  constructor: () ->
  checkApply: (Value) ->
    true
  apply: (Value) ->
    throw new Error 'apply method must be implemented!'

class InitialValue extends Effect
  constructor: (@value) ->
  apply: (value) ->
    if value.value != null
      throw new Error 'can not set initial value twice!'
    value.value = @value

class ModValue extends Effect
  constructor: (@mod) ->
  apply: (value) ->
    if value.value == null
      throw new Error 'can not apply modified without initial value'
    value.value += @mod

class Value
  constructor: () ->
    @value = null
    @effects = []

  toString: () ->
    "(#{@value} #{@prototype})"

  addEffect: (effect) ->
    effect.checkApply(@)
    @effects.push effect
    @recalc()

  removeEffect: (effect) ->
    i = @effects.indexOf(effect)
    if (i == -1)
      throw new Error '#{effect} was not applied to #{@}!'
    @effects.splice(i, 1)
    @recalc()

  recalc: ->
    @value = null
    for e in @effects
      e.apply this
    return # avoid building an array

class EffectsProvider
  constructor: () ->
    @effects = []

  applyEffects: (root) ->
    if (!root)
      return
    for key, effect of @effects
      value = getPath root, key
      value.addEffect effect
    return # avoid building an array

  unApplyEffects: (root) ->
    if (!root)
      return
    for key, effect of @effects
      value = getPath root, key
      value.removeEffect effect
    return # avoid building an array


do (exports = exports ? @basetypes = {}) ->
  exports.Effect = Effect
  exports.ModValue = ModValue
  exports.InitialValue = InitialValue
  exports.Value = Value
  exports.EffectsProvider = EffectsProvider