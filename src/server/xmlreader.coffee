sax = require 'sax'

saxStrict = true
saxOpts =
    trim: true
    normalize: false
    xmlns: false
    
isEmpty = (o) ->
    for own key, value of o
        return false
    return true
    
applyValue = (object, propName, value) ->
    if object.hasOwnProperty(propName) 
        currentValue = object[propName]
        if currentValue instanceof Array
            currentValue.push value
        else
            object[propName] = [ currentValue, value ]
    else
        object[propName] = value


read = (input) ->
    parser = sax.parser saxStrict, saxOpts
    
    objects = []
    current = {}
    text = ""
    
    parser.onerror = (err) ->
        throw err
    
    parser.onopentag = (tag) ->
        objects.push current
        current = {}
        text = ""
        
    parser.ontext = (newText) ->
        text += newText
        
    parser.onclosetag = (tagName) ->
        value = current
        if isEmpty value
            value = text || true
        current = objects.pop()
        applyValue(current, tagName, value)
        text = ""

    parser.write input
    for key, value of current
        return {} if value == true
        return value

exports.read = read