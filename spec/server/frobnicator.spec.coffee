f = require '../../src/server/frobnicator'
frob = f.frob
eyes = require 'eyes'

describe 'Frobnicator', ->
    it 'keeps an empty object', ->
        expect(frob {}, {}).toEqual {}
    describe 'list mapper', ->
        fooSpec = foos: f.listToIndex 'foo', 'id'
        it 'does a simple mapping', ->
            input = foos: foo: [{ id: 1}, { id:2 }]
            expect(frob input, fooSpec).toEqual foos: { '1': { id: 1}, '2': {id: 2}}
        it 'does an empty mapping if the property is the empty list', ->
            input = foos: foo: []
            expect(frob input, fooSpec).toEqual foos: {}
        it 'throws if element is not an array', ->
            input = foos: foo: 'bar'
            expect(-> frob input, fooSpec).toThrow()
        it 'throws if an unexpected element exists', ->
            input = foos: { foo: [], bar: true }
            expect(-> frob input, fooSpec).toThrow()
        it 'throws if an element does not contain the correct key', ->
            input = foos: foo: [ { bar: true } ]
            expect(-> frob input, fooSpec).toThrow()
        it 'has a useful toString()', ->
            expect(f.listToIndex('el', 'id').toString()).toEqual('ListToIndex(el, id)')
