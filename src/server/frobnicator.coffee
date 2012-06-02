frob = (object, spec) ->
    if not spec?
        return object
        
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

getOnlyElement = (input, elementName) ->
    element = input[elementName]
    for own attr, value of input
        if attr != elementName
            throw new Error "unexpected property #{attr} (only #{elementName} expected)"
    return element
    
class ListToIndex extends Conversion
    constructor: (@elementName, @id, @childSpec) ->
        
    convert: (input) ->
        list = getOnlyElement(input, @elementName)
        if list not instanceof Array
            if @id of list
                # a single element that should have been in a list
                list = [list]
            else
                throw new Error "property #{@elementName} should be an array, is #{list}"
        result = {}
        for element in list
            if @id not of element
                throw new Error "property named #{@id} missing in element #{element}"
            idValue = element[@id]
            element = frob(element, @childSpec)
            result[idValue] = element
        return result
        
    toString: ->
        "#{@constructor.name}(#{@elementName}, #{@id})"
        
class ValueList extends Conversion
    constructor: (@elementName) ->
        
    convert: (input) ->
        list = getOnlyElement(input, @elementName)
        if list not instanceof Array then list = [list]
        return list        
        
    toString: ->
        "#{@constructor.name}(#{@elementName})"
    
exports.frob = frob

exports.listToIndex = (args...) -> new ListToIndex(args...)
exports.valueList = (args...) -> new ValueList(args...)
