#= require ../common/creation
#= require ../common/data/text

global = @
text = global.text

module = angular.module 'srgen.priority', []

module.directive 'priorityTable', [ ->
  restrict: 'E',
  templateUrl: '/partial/priorityTable'
  link: (scope, elem, attr) ->
    countPrio = (p) ->
      prio = scope.$eval 'prio'
      count = 0
      for k,v of prio
        count++ if p==v
      return count

    scope.priorityUnused = (p) ->
      countPrio(p) == 0
    scope.priorityOverused = (p) ->
      countPrio(p) > 1
]

module.directive 'prioTableMetatype', ['$parse', ($parse) ->
  link: (scope, elem, attr) ->
    obj = $parse(attr.obj)(scope)
    for mt in global.core.metatypes
      if mt of obj then elem.append "<div>#{text.metatype[mt]} (#{obj[mt]})</div>"
    return
]

module.directive 'prioTableMagic', ['$parse', ($parse) ->
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
        return "#{global.text.attributes[a]} #{obj[a]}"

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
    for type in ['magician', 'technomancer', 'adept', 'aspectedMagician']
      if type of obj
        result += "<dt>#{text.creation.priority.magicOrResource[type]}</dt>"
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

module.controller 'PriorityCreationController', ['$scope', ($scope) ->
  $scope.core = global.core
  $scope.text = global.text
  $scope.priority = global.core.creation.priority
  $scope.creation = new global.creation.Creation
  creationState = global.localStorage.getItem('creation')
  if creationState?
    $scope.creation.applyState(angular.fromJson(creationState))
  else
    $scope.creation.setMetatype 'human'
  $scope.char = $scope.creation.char
  $scope.prio = angular.copy $scope.creation.priority
  $scope.$watch 'prio', ->
    for aspect, prio of $scope.prio
      $scope.creation.setPriority(aspect, prio)
      console.log $scope.$eval('creation.points.skills.available')
  , true
  $scope.$watch 'creation', ->
    creationState = $scope.creation.exportState()
    global.localStorage.setItem('creation', angular.toJson(creationState))
  , true
]
