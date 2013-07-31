# just to catch any fault use of require() in the client or common code
@require ?= -> throw Error 'require can not be used on the client side'

# a very primitive "jsonPath" implementation, capable of only what I needed. Not tested for anything else
# specifically, this can only ever return a single object
# the advantage is that it always returns exactly the matched object and not a copy of it
getPath = (obj, path) ->
  segments = path.split '.'
  result = obj
  for s in segments
    result = result[s]
  result

class Effect
  constructor: () ->
  checkApply: (target) ->
    true
  apply: (target) ->
    throw new Error 'apply method must be implemented!'
  unApply: (target) ->
    return # most effects don't need to do anything here

class EffectTarget
  constructor: () ->
    @effects = []

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


class InitialValue extends Effect
  constructor: (@value) ->
  apply: (target) ->
    if target.value != null
      throw new Error 'can not set initial value twice!'
    target.value = @value

class ModValue extends Effect
  constructor: (@mod) ->
  apply: (target) ->
    if target.value == null
      throw new Error 'can not apply modified without initial value'
    target.value += @mod

class Value extends EffectTarget
  constructor: () ->
    @value = null
    @effects = []

  toString: () ->
    "(#{@value})"

class EffectsProvider
  constructor: (@target) ->
    @effects = {}

  applyEffects: ->
    for key, effect of @effects
      value = getPath @target, key
      value.addEffect effect
    return # avoid building an array

  unApplyEffects: ->
    for key, effect of @effects
      value = getPath @target, key
      value.removeEffect effect
    return # avoid building an array

  reApplyEffects: ->
    @unApplyEffects()
    @applyEffects()

do (exports = exports ? @basetypes = {}) ->
  exports.Effect = Effect
  exports.EffectTarget = EffectTarget
  exports.ModValue = ModValue
  exports.InitialValue = InitialValue
  exports.Value = Value
  exports.EffectsProvider = EffectsProvider