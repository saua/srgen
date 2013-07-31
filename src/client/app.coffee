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

main.controller 'ModifierController', [ '$scope', ($scope) ->
  # nothing much: this "requires" a modifier to be available in the scope
]

main.directive 'attributeTable', ['core', 'text', (core, text) ->
  restrict: 'E'
  replace: true
  transclude: false
  controller: 'ModifierController'
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
  controller: '^ModifierController'
  scope:
    char: '@'
    attribute: '@'
  template: '''
            <div class="input-append input-prepend">
            <button class="btn" type="button" ng-click="modifier.decreaseAttribute(attribute)" ng-disabled="modifier.canDecreaseAttribute(attribute)">-</button>
            <input type="text" class="input-mini" ng-model="attribute.value" readonly/>
            <button class="btn" type="button" ng-click="modifier.increaseAttribute(attribute)" ng-disabled="modifier.canIncreaseAttribute(attribute)">+</button>
            </div>
            '''
  link: ($scope, $element, $attrs) ->
    $scope.up = -> $scope.attributes.value++
    $scope.down = -> $scope.attributes.value--

    # move id to input element, so that label for="" works correcly
    $element.find('input').attr('id', $attrs.id)
    $element.removeAttr 'id'

main.controller 'MainController', [ '$rootScope', 'core', 'text', ($rootScope, core, text) ->
  $rootScope.core = core
  $rootScope.text = text
]

angular.bootstrap document, ['srgen.main']