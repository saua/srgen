batman = require 'batman'
eyes = require 'eyes'

class Effect
    applyEffect: (current, calculatedValue) ->
        throw new Error 'Effect must define applyEffect'

class SetEffect extends Effect
    constructor: (@value) ->

    applyEffect: (current, calculatedValue) ->
        if current?
            throw new Error "Value already set to #{current}!"
        return @value

    toString: -> "=#{@value}"

class AddEffect extends Effect
    constructor: (@value) ->

    applyEffect: (current, calculatedValue) ->
        unless current?
            throw new Error "Value not yet set!"
        return current + @value

    toString: ->
        if @value == 0
            '±0'
        else if @value > 0
            "+#{@value}"
        else
            "#{@value}"

class CalculatedValue extends batman.Object
    constructor: ->
        @set('effects', new batman.Set())

    @accessor 'value',
        get: ->
            current = undefined
            @get('effects').forEach (e) ->
                current = e.applyEffect(current, @)
            return current
        set: -> throw new Error 'Can not set calculated value directly'
        unset: -> throw new Error 'Can not unset calculated value directly'


    value: -> @get('value')

    add: (effect) ->
        unless effect.applyEffect?
            throw new Error "Effect must have an applyEffect method: #{effect}"
        @get('effects').add effect

exports.CalculatedValue = CalculatedValue
exports.Effect = Effect
exports.SetEffect = SetEffect
exports.AddEffect = AddEffect