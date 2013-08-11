#= require ../common/character
#= require ../common/creation
#= require ./attributes

character = @character
creation = @creation
localStorage = @localStorage

module = angular.module 'srgen.priority', ['srgen.base', 'srgen.attributes']

module.directive 'priorityTable', [ 'core', 'text', (core, text) ->
  restrict: 'E',
  templateUrl: '/partials/priorityTable'
  scope: {
    creation: '='
  }
  link: (scope, elem, attr) ->
    scope.cprio = core.creation.priority
    scope.tprio = text.creation.priority
    countPrio = (p) ->
      prio = scope.creation.priority
      count = 0
      for k,v of prio
        count++ if p==v
      return count

    scope.priorityUnused = (p) ->
      countPrio(p) == 0
    scope.priorityOverused = (p) ->
      countPrio(p) > 1
]

module.directive 'prioTableMetatype', ['$parse', 'core', ($parse, core) ->
  link: (scope, elem, attr) ->
    obj = $parse(attr.obj)(scope)
    for mt in core.metatypes
      if mt of obj then elem.append "<div>#{text.metatype[mt]} (#{obj[mt]})</div>"
    return
]

module.directive 'prioTableMagic', ['$parse', 'text', ($parse, text) ->
  pt = text.creation.priority
  append = (first, second) ->
    if first and second
      "#{first}, #{second}"
    else if first
      first
    else
      second

  benefits = (obj) ->
    result = attr(obj)
    result = append result, skills(obj)
    result = append result, spellLike(obj)
    return result

  attr = (obj) ->
    for a in ['mag', 'res']
      if a of obj
        return "#{text.attributes[a]} #{obj[a]}"

  skills = (obj) ->
    result = ''
    for type in ['mag', 'res', 'active']
      for quali in ['Skill', 'SkillGroup']
        if type+quali of obj
          result = append result, skillDesc(obj[type+quali], type+quali)
    return result

  skillDesc = (skills, name) ->
    count = {}
    uniq = []
    for s in skills
      if s of count
        count[s]++
      else
        count[s] = 1
        uniq.push s
    uniq.sort
    result = ''
    for rating in uniq
      num = count[rating]
      result = append result, "#{text.fn.smallNum(num)} #{text.term.rating} #{rating} #{text.fn.numTerm(num, name)}"
    return result

  spellLike = (obj) ->
    for sl in ['spell', 'complexForm']
      if sl of obj
        count = obj[sl]
        return "#{text.fn.smallNum(count)} #{text.fn.numTerm(count, sl)}"
    return


  link: (scope, elem, attr) ->
    obj = $parse(attr.obj)(scope)
    result = ''

    magicTypes = core.creation.priority.magicOrResonanceTypes

    # ugly special casing
    if obj['magician']? && angular.equals(obj['magician'], obj['mysticAdept'])
      result += "<dt>#{text.term.magicOrResonanceType.magician} #{text.term.or} #{text.term.magicOrResonanceType.mysticAdept}</dt>"
      result += "<dd>#{benefits(obj.magician)}</dd>"
      magicTypes = magicTypes.slice 2

    for type in magicTypes
      if type of obj
        result += "<dt>#{text.term.magicOrResonanceType[type]}</dt>"
        result += "<dd>#{benefits(obj[type])}</dd>"
    if result
      elem.append "<dl>#{result}</dl>"
    else
      elem.append '-'
    return
]

module.directive 'prioTableSkills', ['$parse', ($parse) ->
  link: (scope, elem, attr) ->
    obj = $parse(attr.obj)(scope)
    elem.append "#{obj.skills} (#{obj.skillGroups})"
]

module.directive 'pointsTable', [ 'text', '$filter', (text, $filter) ->
  restrict: 'E',
  templateUrl: '/partials/pointsTable'
  scope: {
    creation: '='
  }
  link: (scope, elem, attr) ->
    if attr.points?
      scope.pointTypes = attr.points.split(',')
    else
      scope.pointTypes = ['specialAttributes', 'attributes', 'skills', 'skillGroups', 'karma', 'resources']
    scope.pointsText = text.creation.priority.points

    formatValue = (value, type) ->
      if type == 'resources'
        return $filter('currency')(value, '¥')
      else
        return value

    scope.usedPoints = (type) ->
      formatValue scope.creation.points[type].used, type

    scope.availablePoints = (type) ->
      formatValue scope.creation.points[type].available, type
]

module.controller 'PriorityCreationController', ['$scope', 'core', ($scope, core) ->
  $scope.priority = core.creation.priority
  creationState = localStorage.getItem('creation')
  if creationState?
    $scope.creation = new creation.Creation angular.fromJson(creationState)
  else
    $scope.creation = new creation.Creation
    $scope.creation.setMetatype 'human'
  $scope.char = $scope.creation.char
  $scope.prio = angular.copy $scope.creation.priority
  $scope.magicOrResonanceTabName = ->
    if $scope.char.attributes.mag?
      text.ui.tab.magic
    else if $scope.char.attributes.res?
      text.ui.tab.resonance
    else
      text.ui.tab.magicOrResonance

  $scope.magicOrResonanceType = $scope.char.magicType?.name || $scope.char.resonanceType?.name
  $scope.updateMagicOrResonanceType = (mor) ->
    # for some strang reason $scope.magicOrResonanceType is *READ* from this scope, but written to the tab scope
    $scope.magicOrResonanceType = mor
    isMagic = mor of character.MagicType.magicTypes
    isResonance = mor of character.ResonanceType.resonanceTypes

    $scope.creation.setMagicType if isMagic then mor else null
    $scope.creation.setResonanceType if isResonance then mor else null

  $scope.validateMagicOrResonanceType = ->
    $scope.creation.validateMagicType().concat $scope.creation.validateResonanceType()

  $scope.$watch 'creation.priority', ->
    $scope.creation.applyPriorities()
  , true
  $scope.$watch 'creation', ->
    creationState = $scope.creation.exportState()
    localStorage.setItem('creation', angular.toJson(creationState))
  , true
]
