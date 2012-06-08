class Effect
    constructor: (@source) ->
    apply: (value) ->
        value.effects.push(this)
    toString: -> @name
    
class SetEffect extends Effect
    constructor (source, @amount) ->
        super(source)
        
    apply: (value) ->
        if value.isSet()
            throw Error("value is already set!")
        value.value = @amount
        super(value)
        
class AddEffect extends Effect
    constructor (source, @amount) ->
        super(source)
        
    apply: (value) ->
        if not value.isSet()
            throw Error("value is not yet set!")
        value.value += @amount
        super(value)
        
    
class Value
    constructor: ->
        @effects = []
        
    isSet: ->
        @value?
    
class Attribute
    constructor: (@name) ->
        @min = new Value "#{@name} minimum"
        @max = new Value "#{@name} maximum"
        @maxaug = new Value "#{@name} augumented maximum}"
        
    toString: ->
        "#{@name} #{@natural?.value || '-'}"
        
attributeNames =
    'agi': 'agility'
    'bod': 'body'
    'rea': 'reaction'
    'str': 'strength'
    'cha': 'charisma'
    'int': 'intelligence'
    'log': 'logic'
    'wil': 'willpower'
    'edg': 'edge'
    'ess': 'essence'
    'mag': 'magic'
    'res': 'resonance'

class Character
    constructor: ->
        @attributes = {}
        for short of attributeNames
            @attributes[short] = new Attribute short
            
    toString: ->
        result = "Character #{@alias}\n"
        for k,v of @attributes
            result += v + "\n"
        return result
        

exports.Character = Character