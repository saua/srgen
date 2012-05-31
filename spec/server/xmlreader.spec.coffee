xmlreader = require '../../src/server/xmlreader'
eyes = require 'eyes'


expectResult = (input, expected) ->
    xml = "<x>#{input}</x>"
    result = xmlreader.read xml
    # eyes.inspect result, "result of #{input}"
    expect(result).toEqual expected

describe "XML reader", ->
    describe "default behaviour", ->
        it "throws on malformed XML", ->
            expect(-> xmlreader.read 'not XML').toThrow()
        it "parses empty string", ->
            expectResult '', {}
        it "parses boring text", ->
            expectResult 'text', 'text'
        it "parses a tag with text", ->
            expectResult '<foo>text</foo>', { foo: 'text' }
        it "parses a selfclosing tag", ->
            expectResult '<foo />', { foo: true }
        it "parses an empty tag", ->
            expectResult '<foo></foo>', { foo: true }
        it "parses mixed tags", ->
            expectResult '<foo>text</foo><bar />', { foo: 'text', bar: true }
        it "parses nested tags", ->
            expectResult '<foo><bar>text</bar></foo>', { foo: { bar: 'text' }}
        it "parses double tags", ->
            expectResult '<foo /><foo />', { foo: [ true, true] }
        it "parses mixed double tags", ->
            expectResult '<foo /><foo >text</foo><foo><bar /></foo>', { foo: [ true, 'text', { bar: true } ] }

