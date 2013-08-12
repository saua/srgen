bt = require '../../src/common/basetypes.coffee'

describe 'Value', ->
  it 'has initial value null', ->
    expect(new bt.Value().value).toBe null

  describe 'Listener', ->
    v = null
    listener = null

    beforeEach ->
      v = new bt.Value
      listener = jasmine.createSpy('listener')

    it 'allows listeners to be added', ->
      expect(-> v.addListener listener).not.toThrow()

    it 'calls the listener when the value changes', ->
      v.addListener listener
      v.addEffect new bt.InitialValue 1
      expect(listener).toHaveBeenCalled()

    it 'does not matter how often the same listener is added', ->
      v.addListener listener
      v.addListener listener
      v.addEffect new bt.InitialValue 1
      expect(listener).toHaveBeenCalled()

    it 'does not call the listener when the value does not change', ->
      v.addEffect new bt.InitialValue 1
      v.addListener listener
      v.addEffect new bt.ModValue +0
      expect(listener).not.toHaveBeenCalled()

    it 'does call the listener when the value changes', ->
      v.addEffect new bt.InitialValue 1
      v.addListener listener
      v.addEffect new bt.ModValue +1
      expect(listener).toHaveBeenCalled()

describe 'Effect', ->
  v = null

  beforeEach ->
    v = new bt.Value

  it 'throws when using a plain Effect', ->
    expect(-> v.addEffect new bt.Effect).toThrow()

  it 'sets the value when using InitialValue', ->
    v.addEffect new bt.InitialValue 1
    expect(v.value).toBe 1

  it 'does not have any errors without effects', ->
    expect(v.errors).toEqual []

  it 'reports an error when setting two initial values', ->
    v.addEffect new bt.InitialValue 1
    v.addEffect new bt.InitialValue 2
    expect(v.errors).not.toEqual []

  it 'reports an error if trying to use a mod effect without an initial', ->
    v.addEffect new bt.ModValue 1
    expect(v.errors).not.toEqual []

  it 'applies the mod effect after an initial', ->
    v.addEffect new bt.InitialValue 1
    v.addEffect new bt.ModValue +1
    expect(v.value).toBe(2)

  it 'accepts a mod effect without an inital', ->
    v.addEffect new bt.ModValue +1

  it 'applies mod effects cummulatively', ->
    v.addEffect new bt.InitialValue 1
    v.addEffect new bt.ModValue +1
    v.addEffect new bt.ModValue +1
    expect(v.value).toBe 3

  describe 'CalculatedEffect', ->
    cv = null
    v2 = null

    beforeEach ->
      v.addEffect new bt.InitialValue 0
      cv = new bt.CalculatedEffect
      cv.calculate = (target) ->
        @registerWith v
        return v.value
      v2 = new bt.Value

    it 'initially calculates correctly', ->
      v2.addEffect cv
      expect(v2.value).toBe v.value

    it 'follows changes to the listened-upon value', ->
      v2.addEffect cv
      v.addEffect new bt.ModValue +1
      expect(v2.value).toBe v.value

    it 'can be used to modify a value', ->
      v2.addEffect new bt.InitialValue 1
      cv.calculate = (target) ->
        @registerWith v
        return target.value + v.value
      v2.addEffect cv
      expect(v2.value).toBe 1+v.value
      v.addEffect new bt.ModValue +1
      expect(v2.value).toBe 1+v.value

describe 'EffectsProvider', ->
  root = null
  eb = null

  beforeEach ->
    root =
      v: new bt.Value
      n:
        nv: new bt.Value
    eb = new bt.EffectsProvider root

  it 'can set a simple value', ->
    eb.add 'v', new bt.InitialValue 1
    eb.applyEffects()
    expect(root.v.value).toBe 1

  it 'can apply multiple effects to a single value', ->
    eb.add 'v', new bt.InitialValue(1)
    eb.add 'v', new bt.ModValue(1)
    eb.applyEffects()
    expect(root.v.value).toBe 2

  it 'can set a nested value', ->
    eb.add 'n.nv', new bt.InitialValue 1
    eb.applyEffects()
    expect(root.n.nv.value).toBe 1