angular.module "root", ["siteTitle"]

angular.module "siteTitle", []
  .constant "siteTitle", "LyricScreen"
  .controller "siteTitle", ["$scope", "siteTitle", ($scope, siteTitle) ->
    $scope.siteTitle = siteTitle
  ]

