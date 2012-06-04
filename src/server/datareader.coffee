xmlreader = require './xmlreader'
frobnicator = require './frobnicator'

fs = require 'fs'
path = require 'path'

dataDir = 'data'
versions = {}

read = (name, frobSpec, attr) ->
    xml = fs.readFileSync(path.join(dataDir, "#{name}.xml"), 'utf-8')
    json = xmlreader.read xml
    versions[name] = delete json.version
    result = frobnicator.frob json, frobSpec
    return if attr? then result[attr] else result
    
readBooks = ->
    spec = books: frobnicator.listToIndex 'book', 'code'
    read 'books', spec, 'books'

readMetatypes = ->
    spec =
        categories: frobnicator.valueList('category')
        metatypes: frobnicator.listToIndex('metatype', 'name',
            metavariants: frobnicator.listToIndex 'metavariant', 'name')
    read 'metatypes', spec
    
allReaders = {
    readBooks,
    readMetatypes
}

readAll = ->
    result = { versions }
    for functionName, reader of allReaders
        name = functionName.replace(/^read/,'').toLowerCase()
        result[name] = reader()
    return result

for k,v of allReaders
    exports[k] = v
exports.readAll = readAll;
    
