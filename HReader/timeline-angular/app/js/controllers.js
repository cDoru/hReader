'use strict';

/* Controllers


function RecordListCtrl($scope) {
  $scope.records = [
    {"description": "Blood Pressure",
	"scalar": "118.0", 
    "units": "mm[Hg]"},
    {"description": "Blood Pressure",
	"scalar": "108.0", 
    "units": "mm[Hg]"},
    {"description": "Blood Pressure",
	"scalar": "110.0", 
    "units": "mm[Hg]"},
  ];

  $scope.orderProp = 'date'
}



*/

/* TESTING Code
  var values = {description: 'Systolic Blood Pressure'};
  var log = [];
  angular.forEach(values, function(value, key){
  this.push(key + ': ' + value);
  }, log);
  expect(log).toEqual(['description: Systolic Blood Pressure']);
*/

// function TimelineWeekCtrl($scope, $routeParams) {
//   $scope.week = $routeParams.week;
// }

// //TimelineWeekCtrl.$inject - ['$scope', '$routeParams'];

// function Cntrl ($scope, $location) {
//   $scope.changeView = function(view){
//       $location.path(view); 
//   }
// }


/* Raw Controller Code */
// function RecordListCtrl($scope, $http) {
//   $http.get('records/hs.json').success(function(data) {
//     $scope.vitals = {};
//     var i, vitals;
//     for (i in data.vital_signs) {
//       vitals = data.vital_signs[i];
//       var value = $scope.vitals[vitals.description] || [];
//       value.push(parseInt(vitals.value,10));
//       $scope.vitals[vitals.description] = value;
//     };
//   });
// };

/*  */
// function DayListCtrl($scope, $http) {
//   $http.get('records/timeline-serve.json').success(function(data) {
//     $scope.vitals = {};
//     var i, vitals;
//     for (i in data.vital) {
//       vitals = data.vitals[i];
//       var value = $scope.vitals[vitals.description] || [];
//       value.push(parseInt(vitals.value,10));
//       $scope.vitals[vitals.description] = value;
//     };
//   });
// };

// function DecadeListCtrl($scope, $http) {
//   $http.get('records/timeline-serve.json').success(function(data) {
//     $scope.vitals = {};

//   });
// }


// function DayListCtrl($scope, $http) {
//   $http.get('records/timeline-serve.json').success(function(data) {
//     $scope.vitals = data.vitals;

//   });
// };
 

/* iPad */

function DayListCtrl($scope, $http) {
  $http.get('timeline.json?page=day').success(function(data) {
    $scope.vitals = data.vitals;
    $scope.symptoms = 'New Symptom'; 


  });
};

function WeekListCtrl($scope, $http) {
  $http.get('timeline.json?page=week').success(function(data) {
    $scope.vitals = data.vitals;

  });
};

function MonthListCtrl($scope, $http) {
  $http.get('timeline.json?page=month').success(function(data) {
    $scope.vitals = data.vitals;

  });
};
function YearListCtrl($scope, $http) {
  $http.get('timeline.json?page=year').success(function(data) {
    $scope.vitals = data.vitals;

  });
};
function DecadeListCtrl($scope, $http) {
  $http.get('timeline.json?page=decade').success(function(data) {
    $scope.vitals = data.vitals;

  });
};


// DayListCtrl.$inject = ['values', '$http'];


//PhoneDetailCtrl.$inject = ['$scope', '$http'];

