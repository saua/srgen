#= require ../common/character
#= require ../common/creation
#= require ../common/data/text

global = @
main = angular.module "main", ["ui.bootstrap"]
main.directive "attributeEditor", () ->
  restrict: 'E'
  replace: true
  transclude: false
  scope:
    attributes: '='
  template: '''
            <div class="input-append input-prepend">
            <button class="btn" type="button" ng-click="down()" ng-disabled="attribute.value <= attribute.min">-</button>
            <input type="text" class="input-mini" ng-model="attribute.value" readonly/>
            <button class="btn" type="button" ng-click="up()" ng-disabled="attribute.value >= attribute.max">+</button>
            </div>
            '''
  link: ($scope, $element, $attrs) ->
    $scope.up = -> $scope.attributes.value++
    $scope.down = -> $scope.attributes.value--

    # move id to input element, so that label for="" works correcly
    $element.find('input').attr('id', $attrs.id)
    $element.removeAttr 'id'

main.controller "ShadowrunController", ["$scope", ($scope) ->
  $scope.core = global.core
  $scope.text = global.text
  $scope.creation = new global.creation.Creation
  $scope.char = $scope.creation.char
  $scope.creation.setMetatype 'human'
]

angular.bootstrap document, ["main"]