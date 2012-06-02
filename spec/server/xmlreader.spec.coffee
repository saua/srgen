xmlreader = require '../../src/server/xmlreader'


expectResult = (input, expected) ->
    xml = "<x>#{input}</x>"
    result = xmlreader.read xml
    expect(result).toEqual expected

describe 'XML Reader', ->
    describe 'error conditions', ->
        it 'throws on malformed XML', ->
            expect(-> xmlreader.read 'not XML').toThrow()
    describe 'trivial input', ->
        it 'parses empty string', ->
            expectResult '', {}
        it 'parses boring text', ->
            expectResult 'text', 'text'
        it 'parses a tag with text', ->
            expectResult '<foo>text</foo>', { foo: 'text' }
        it 'parses a selfclosing tag', ->
            expectResult '<foo />', { foo: true }
        it 'parses an empty tag', ->
            expectResult '<foo></foo>', { foo: true }
        it 'handles attributes', ->
            expectResult '<foo attr="text" />', { foo: { attr: 'text' }}
        it 'trims text', ->
            expectResult '<foo> abc </foo>', { foo: 'abc' }
    describe 'mixed input', ->
        it 'parses mixed tags', ->
            expectResult '<foo>text</foo><bar />', { foo: 'text', bar: true }
        it 'parses nested tags', ->
            expectResult '<foo><bar>text</bar></foo>', { foo: { bar: 'text' }}
        it 'parses double tags', ->
            expectResult '<foo /><foo />', { foo: [ true, true] }
        it 'parses mixed double tags', ->
            expectResult '<foo /><foo >text</foo><foo><bar /></foo>', { foo: [ true, 'text', { bar: true } ] }
        it 'handles attributes together with nested tags', ->
            expectResult '<foo attr="text"><bar>text</bar></foo>', { foo: { attr: 'text', bar: 'text' }}
    describe 'data that looks like actual Chummer data', ->
        it 'handles book-like input', ->
            expectResult '<books><book><name>A Book</name><code>AB</code></book><book><name>Different Book</name><code>DB</code></book></books>',
                books: {book: [ { name: 'A Book', code: 'AB' }, { name: 'Different Book', code: 'DB' } ] }