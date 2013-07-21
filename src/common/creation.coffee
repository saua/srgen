#= ./character
char = @char ? require('./character')

class Creation
  constructor: ->
    @char = new char.Character

  setMetatype: (name) ->
    @char.setMetatype name

do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation
