data = require '../../src/server/datareader'

describe 'Data Reading', ->
    
    beforeEach ->
        @addMatchers
            toHaveProperty: (prop) ->
                prop of @actual
    
    describe 'books.xml', ->
        books = data.readBooks()
        
        it 'includes SR4', ->
            sr4 = books['SR4']
            expect(sr4).toBeDefined()
            expect(sr4.name).toEqual 'Shadowrun 4th Edition'

    describe 'metatypes.xml', ->
        metatypes = data.readMetatypes()

        it 'includes categories', ->
            expect(metatypes).toHaveProperty('categories')
            expect(metatypes.categories).toContain('Metahuman')

        it 'includes Human', ->
            expect(metatypes.metatypes).toHaveProperty('Human')
            
        it 'includes Human Metavariant Nartaki', ->
            expect(metatypes.metatypes['Human'].metavariants).toHaveProperty('Nartaki')
            
        it 'includes Elf Metavariant Xapiri Thëpë', ->
            expect(metatypes.metatypes['Elf'].metavariants).toHaveProperty('Xapiri Thëpë')

    describe 'readAll', ->
        all = data.readAll()
        categories = ['books', 'metatypes']
        
        for cat in ['books', 'metatypes']
            it "reads #{cat}", ->
                expect(all).toHaveProperty(cat)
                expect(all.versions).toHaveProperty(cat)

