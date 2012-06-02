xmlreader = require './xmlreader'
frobnicator = require './frobnicator'

fs = require 'fs'
path = require 'path'

dataDir = 'data'
versions = {}

read = (name) ->
    xml = fs.readFileSync(path.join(dataDir, "#{name}.xml"), 'utf-8')
    json = xmlreader.read xml
    versions[name] = json.version
    return json
    
readBooks = ->
    json = read 'books'
    spec = books: frobnicator.listToIndex 'book', 'code'
    frobnicator.frob(json, spec).books
    
allReaders = {
    readBooks
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
    
