#= require ./priority
#= require ../common/character
#= require ../common/creation
#= require ../common/data/core
#= require ../common/data/text

core = @core
text = @text

data = angular.module 'srgen.data', []
data.service 'core', ->
  core

data.service 'text', ->
  text

main = angular.module 'srgen.main', ['srgen.data', 'srgen.priority', 'ui.bootstrap']

main.directive 'attributeTable', ['core', 'text', (core, text) ->
  restrict: 'E'
  replace: true
  transclude: false
  scope:
    char: '='
    modifier: '='
  templateUrl: 'partial/attributeTable'
  link: ($scope, $element, $attrs) ->
    $scope.core = core
    $scope.text = text
]


main.directive 'attributeEditor', ->
  restrict: 'E'
  replace: true
  transclude: false
  scope:
    char: '='
    modifier: '='
    attribute: '@'
  templateUrl: 'partial/attributeEditor',
  link: ($scope, $element, $attrs) ->
    # move id to input element, so that label for="" works correcly
    $element.find('input').attr('id', $attrs.id)
    $element.removeAttr 'id'

main.controller 'MainController', [ '$rootScope', 'core', 'text', ($rootScope, core, text) ->
  $rootScope.core = core
  $rootScope.text = text
]

angular.bootstrap document, ['srgen.main']