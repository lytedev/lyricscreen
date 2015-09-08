(function() {
  angular.module("root", ["siteTitle"]);

  angular.module("siteTitle", []).constant("siteTitle", "LyricScreen").controller("siteTitle", [
    "$scope", "siteTitle", function($scope, siteTitle) {
      return $scope.siteTitle = siteTitle;
    }
  ]);

}).call(this);
