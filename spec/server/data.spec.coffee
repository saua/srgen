data = require '../../src/server/data'

describe 'Data Reading', ->
    describe 'books.xml', ->
        books = data.readBooks()
        
        it 'includes SR4', ->
            sr4 = books['SR4']
            expect(sr4).toBeDefined()
            expect(sr4.name).toEqual 'Shadowrun 4th Edition'

    describe 'readAll()', ->
        all = data.readAll()
        it 'reads books', ->
            expect(all.books).toBeDefined()
            expect(all.versions.books).toBeDefined()
            
            