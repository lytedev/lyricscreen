angular.module "root", ["siteTitle"]

angular.module "siteTitle", []
  .constant "siteTitle", "LyricScreen"
  .controller "siteTitle", ["$scope", "siteTitle", ($scope, siteTitle) ->
    $scope.siteTitle = siteTitle
  ]

host = window.location.host
connectionString = host
sock = new WebSocket "ws://" + connectionString

