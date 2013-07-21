#= require ./character
character = @character ? require('./character')

class Creation
  constructor: ->
    @char = new character.Character

  setMetatype: (name) ->
    @char.setMetatype name

do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation
