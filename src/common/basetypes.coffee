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
    if not result?
      return
  return result

class Effect
  constructor: (priority = 1000) ->
    @priority = priority
  apply: (target) ->
    throw new Error 'apply method must be implemented!'
  unApply: (target) ->
    return # most effects don't need to do anything here
  toString: ->
    @.constructor.name

class EffectTarget
  constructor: () ->
    @effects = []
    @errors = []

  addEffect: (effect) ->
    i = @effects.indexOf effect
    if i != -1
      throw new Error "Re-adding #{effect} to #{@}!"
    @effects.push effect
    @recalc()

  removeEffect: (effect) ->
    i = @effects.indexOf effect
    return if i == -1
    @effects.splice i, 1
    @recalc()

  recalc: ->
    @errors.splice 0, @errors.length
    @effects.sort (a,b) -> a.priority - b.priority
    for e in @effects
      e.apply this
    return # avoid building an array

  addError: (err) ->
    @errors.push(err)


class InitialValue extends Effect
  constructor: (@value) ->
    super(0)

  apply: (target) ->
    if target.value != null
      target.addError 'can not set initial value twice!'
      return
    target.value = @value

class ModValue extends Effect
  constructor: (@mod) ->
    super()

  apply: (target) ->
    if target.value == null
      target.addError 'can not apply modified without initial value'
      return
    target.value += @mod

class CalculatedEffect extends Effect
  constructor: ->
    super
    @listener = => @dependentChanged arguments...

  apply: (target) ->
    if not @target? || @target() != target
      @target = -> target
    target.value = @calculate(target)

  registerWith: (dependent) ->
    dependent.addListener @listener

  dependentChanged: (dependent) ->
    if @target?
      @target().recalc()

  calculate: (target) ->
    target.addError "calculate not implemented on #{@}"
    return


class Value extends EffectTarget
  constructor: () ->
    super
    @value = null

  recalc: ->
    originalValue = @value
    @value = null
    super
    if originalValue != @value
      @notifyListeners()

  notifyListeners: ->
    if not @listeners?
      return
    for listener in @listeners()
      listener @

  addListener: (listener) ->
    if not @listeners?
      listeners = []
      @listeners = -> listeners
    if @listeners().indexOf(listener) == -1
      @listeners().push(listener)

  removeListener: (listener) ->
    if not @listeners?
      return
    index = @listeners().indexOf(listener)
    if index != -1
      @listeners().splice(index, 1)

  toString: () ->
    "(#{@value})"

class EffectsProvider
  constructor: (target) ->
    @effects = []
    @target = -> target

  applyEffects: ->
    for [path, effect] in @effects
      value = getPath @target(), path
      value.addEffect effect
    return # avoid building an array

  unApplyEffects: ->
    for [path, effect] in @effects by -1
      value = getPath @target(), path
      if not value?
        continue
      effect.unApply value
      value.removeEffect effect
    return # avoid building an array

  add: (path, effect) ->
    @effects.push [path, effect]

  remove: (path, effect) ->
    for [p, e], i in @effects
      if p == path && e == effect
        @effects.splice i, 1
        return
    return

  reApplyEffects: ->
    @unApplyEffects()
    @applyEffects()

do (exports = exports ? @basetypes = {}) ->
  exports.Effect = Effect
  exports.EffectTarget = EffectTarget
  exports.ModValue = ModValue
  exports.InitialValue = InitialValue
  exports.CalculatedEffect = CalculatedEffect
  exports.Value = Value
  exports.EffectsProvider = EffectsProvider
