#= require ./character
#= require ./data/core
character = @character ? require './character'
core = @core ? require './data/core'
cp = core.creation.priority

class Creation
  constructor: ->
    @char = new character.Character
    @priority =
      metatype: null
      attributes: null
      magic: null
      skills: null
      resources: null
    defaultPoints = -> available: 0, used: 0
    @points =
      attributes: defaultPoints()
      specialAttributes: defaultPoints()
      skills: defaultPoints()
      skillGroups: defaultPoints()
      resources: defaultPoints()
      karma: available: 25, used: 0
    @metatype = null

  setMetatype: (name) ->
    @metatype = name
    @char.setMetatype name
    @applyPriorities()

  setPriority: (aspect, priority) ->
    throw new Error "Unknown aspect #{aspect}" unless aspect of @priority
    throw new Error "Invalid priority #{priority}" unless priority in cp.priorities
    return if @priority[aspect] == priority
    @priority[aspect] = priority
    @applyPriorities()

  applyPriorities: () ->
    getAspectPriority = (aspect) => cp.aspect[aspect][@priority[aspect]]

    metatype = getAspectPriority 'metatype'
    if metatype?
      @points.specialAttributes.available = metatype[@metatype]

    attributes = getAspectPriority 'attributes'
    if attributes?
      @points.attributes.available = attributes

    magic = getAspectPriority 'magic'
    # TODO: Magic

    skills = getAspectPriority 'skills'
    if skills?
      @points.skills.available = skills.skills
      @points.skillGroups.available = skills.skillGroups

    resources = getAspectPriority 'resources'
    if resources?
      @points.resources.available = resources

  exportState: () ->
    priority: @priority
    metatype: @metatype
    name: @char.name


  applyState: (state) ->
    @setMetatype state.metatype
    for aspect, prio of state.priority
      @setPriority aspect, prio
    @char.name = state.name

do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation