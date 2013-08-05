attributes = angular.module 'srgen.attributes', ['srgen.base', 'ui.bootstrap']

attributes.directive 'attributeTable', ['core', 'text', (core, text) ->
  restrict: 'E'
  replace: true
  transclude: false
  scope:
    char: '='
    modifier: '='
  templateUrl: '/partials/attributeTable'
  link: ($scope, $element, $attrs) ->
    $scope.core = core
    $scope.text = text
]

attributes.directive 'attributeEditor', ->
  restrict: 'E'
  replace: true
  transclude: false
  scope:
    char: '='
    modifier: '='
    attribute: '@'
  templateUrl: '/partials/attributeEditor',
  link: ($scope, $element, $attrs) ->
    # move id to input element, so that label for="" works correcly
    $element.find('input').attr('id', $attrs.id)
    $element.removeAttr 'id'