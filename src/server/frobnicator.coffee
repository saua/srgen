frob = (object, spec) ->
    for attr, conv of spec
        if attr of object
            value = object[attr]    
            newValue = conv.convert(value)
            object[attr] = newValue
        else
            newValue = conv.missing object
            if newValue != null
                object[attr] = value
    return object

class Conversion
    convert: (input) -> input
    missing: (parent) -> null
    toString: -> @constructor.name
            
        
class ListToIndex extends Conversion
    constructor: (@elementName, @id) ->
        
    convert: (input) ->
        list = input[@elementName]
        for own attr, value of input
            if attr != @elementName
                throw new Error "unexpected property #{attr} (only #{@elementName} expected)"
        if list not instanceof Array
            throw new Error "property #{@elementName} should be an array, is #{list}"
        result = {}
        for element in list
            if @id not of element
                throw new Error "property named #{@id} missing in element #{element}"
            idValue = element[@id]
            result[idValue] = element
        return result
        
    toString: ->
        "#{super()}(#{@elementName}, #{@id})"
    
exports.frob = frob

exports.listToIndex = (args...) -> new ListToIndex(args...)
