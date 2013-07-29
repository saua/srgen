#= require ./character
#= require ./data/core
#= require ./basetypes
character = @character ? require './character'
core = @core ? require './data/core'
basetypes = @basetypes ? require './basetypes'

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

  setMagicType: (magicType) ->
    @char.setMagicType magicType || null
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
    if magic? and @char.magicType?
      specificMagicAspect = magic[@char.magicType.name]
      if specificMagicAspect
        @char.magicType.effects['attributes.mag.value'] = new basetypes.InitialValue specificMagicAspect.mag
        @char.magicType.applyEffects(@char)


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
    magicType: @char.magicType?.name || null


  applyState: (state) ->
    @setMetatype state.metatype if state.metatype
    for aspect, prio of state.priority
      @setPriority aspect, prio if prio
    @setMagicType state.magicType
    @char.name = state.name

do (exports = exports ? @creation = {}) ->
  exports.Creation = Creation