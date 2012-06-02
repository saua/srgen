f = require '../../src/server/frobnicator'
frob = f.frob
eyes = require 'eyes'

describe 'Frobnicator', ->
    it 'keeps an empty object', ->
        expect(frob {}, {}).toEqual {}
    describe 'listToIndex', ->
        fooSpec = foos: f.listToIndex 'foo', 'id'
        it 'does a simple mapping', ->
            input = foos: foo: [{ id: 1}, { id:2 }]
            expect(frob input, fooSpec).toEqual foos: { '1': { id: 1}, '2': {id: 2}}
        it 'works with a single element', ->
            input = foos: foo: { id: 1}
            expect(frob input, fooSpec).toEqual foos: { '1': { id: 1}}
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
        it 'handles child specs', ->
            withChildSpec = foos: f.listToIndex('foo', 'id', bars: f.listToIndex 'bar', 'id')
            input = foos: foo: [{ id: 1, bars: bar: [{ id: 1 }] }]
            expect(frob input, withChildSpec).toEqual
                foos: { 1: { id: 1, bars: { 1: { id: 1} } } }
        it 'has a useful toString', ->
            expect(f.listToIndex('el', 'id').toString()).toEqual('ListToIndex(el, id)')
    describe 'valueList', ->
        foosSpec = foos: f.valueList 'foo'
        it 'works on a simple list', ->
            input = foos: foo: [1, 2, 3]
            expect(frob input, foosSpec).toEqual foos: [1, 2, 3]
        it 'works on a single value', ->
            input = foos: foo: 1
            expect(frob input, foosSpec).toEqual foos: [1]
        it 'works on the empty list', ->
            input = foos: foo: []
            expect(frob input, foosSpec).toEqual foos: []
        it 'fails when a wrong attribut exists', ->
            input = foos: bar: true
            expect(-> frob input, fooSpec).toThrow()
        it 'has a useful toString', ->
            expect(f.valueList('foo').toString()).toEqual('ValueList(foo)')
