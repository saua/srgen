#= require ../common/data/core.js
#= require ../common/data/text
main = angular.module "main", ["ui.bootstrap"]
main.directive "attributeEditor", () ->
  restrict: 'E'
  replace: true
  transclude: false
  scope:
    attribute: '='
  template: '''
            <div class="input-append input-prepend">
            <button class="btn" type="button" ng-click="down()" ng-disabled="attribute.value <= attribute.min">-</button>
            <input type="text" class="input-mini" ng-model="attribute.value" readonly/>
            <button class="btn" type="button" ng-click="up()" ng-disabled="attribute.value >= attribute.max">+</button>
            </div>
            '''
  link: ($scope, $element, $attrs) ->
    $scope.up = -> $scope.attribute.value++
    $scope.down = -> $scope.attribute.value--

    # move id to input element, so that label for="" works correcly
    $element.find('input').attr('id', $attrs.id)
    $element.removeAttr 'id'

main.controller "ShadowrunController", ["$scope", ($scope) ->
  $scope.core = core
  $scope.text = text
  $scope.attribute = {}
  for attr in core.attribute.physicalMental
    limits = core.metatype.human.attribute[attr]
    $scope.attribute[attr] = value: limits.min, min: limits.min, max: limits.max
]
angular.bootstrap document, ["main"]