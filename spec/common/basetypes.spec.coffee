bt = require '../../src/common/basetypes.coffee'

describe 'Value', ->
  it 'has initial value null', ->
    expect(new bt.Value().value).toBe null

describe 'Effect', ->
  v = null

  beforeEach ->
    v = new bt.Value

  it 'throws when using a plain Effect', ->
    expect(-> v.addEffect new bt.Effect).toThrow()

  it 'sets the value when using InitialValue', ->
    v.addEffect new bt.InitialValue 1
    expect(v.value).toBe(1)

  it 'throws when setting two initial values', ->
    v.addEffect new bt.InitialValue 1
    expect(-> v.addEffect(new bt.InitialValue 2)).toThrow()

  it 'throws if trying to use a mod effect without an initial', ->
    expect(-> v.addEffect(new bt.ModValue 1)).toThrow()

  it 'applies the mod effect after an initial', ->
    v.addEffect new bt.InitialValue 1
    v.addEffect new bt.ModValue +1
    expect(v.value).toBe(2)

  it 'applies mod effects cummulatively', ->
    v.addEffect new bt.InitialValue 1
    v.addEffect new bt.ModValue +1
    v.addEffect new bt.ModValue +1
    expect(v.value).toBe 3

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
    eb.effects["v"] = new bt.InitialValue 1
    eb.applyEffects()
    expect(root.v.value).toBe 1

  it 'can set a nested value', ->
    eb.effects["n.nv"] = new bt.InitialValue 1
    eb.applyEffects()
    expect(root.n.nv.value).toBe 1