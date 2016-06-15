'use strict';

var app = angular.module('spoopApp', ['moment-picker', 'rzModule']);

app
.config(['momentPickerProvider', function (momentPickerProvider) {
     momentPickerProvider.options({
         /* Picker properties */
         locale:        'en',
         format:        'LL LT',
         minView:       'month',
         maxView:       'minute',
         startView:     'day',
         today:         false,
         
         /* Extra: Views properties */
         leftArrow:     '&larr;',
         rightArrow:    '&rarr;',
         yearsFormat:   'YYYY',
         monthsFormat:  'MMM',
         daysFormat:    'D',
         hoursFormat:   'HH:[00]',
         minutesFormat: moment.localeData().longDateFormat('LT').replace(/[aA]/, ''),
         secondsFormat: 'ss',
         minutesStep:   1,
         secondsStep:   1
     });
 }])
// .factory('DonorLog', ['$resource', function ($resource) {

//   return $resource('/users/' + gon.user_id + '/donor_logs/:id',
//     {id: '@id'}, { update: { method: 'PUT' } });

// }])
.controller('DonorInsightsController', ['$scope', '$http', function ($scope, $http) {
	
	$scope.sortType = 'donor_number';
	$scope.sortReverse = false;
	$scope.search = {};

	$scope.data = {};

	$http.get('/admin/donor-insights.json')
		.then(function (res) {
			console.log(res);
			$scope.data.donorLogs = res.data.logs;
			$scope.data.tags = res.data.tags;
		})
		.catch(function (err) {
			console.log(err);
		});

	// $scope.data.donorLogs = gon.donor_logs;
}])

.controller('CreateDonorLogController', ['$scope', '$http', function ($scope, $http) {

	function initNewDonorLog () {
	  $scope.donor_log = {};
	  $scope.donor_log.donated = true;
	  $scope.donor_log.processable = true;
	  $scope.donor_log.bristol_score = 4;
	  $scope.donor_log.weight = 65;
	  $scope.donor_log.time_of_passage = moment();
	  $scope.donor_log.notes = '';
	}
	initNewDonorLog();

	// watch donated
	$scope.$watch('donor_log.donated', function (newData) {
	  // $log.log(newData);
	  if (!newData && $scope.donor_log.processable) {
	    $scope.donor_log.processable = false;
	  }
	});
	//watch processable
	$scope.$watch('donor_log.processable', function (newData) {
	  // $log.log(newData);
	  if (newData && !$scope.donor_log.donated) {
	    $scope.donor_log.donated = true;
	  }
	});


	var colors = [
		'#5C2E00',
		'#703800',
		'#854200',
		'#9A4D00',
		'#AB5500',
		'#BC5D00',
		'#CD6600'
	];
	//bristol
	$scope.bristolSliderOptions = {
		floor: 1,
		ceil: 7,
		showSelectionBar: true,
    getSelectionBarColor: function (value) {
    	return colors[value-1];
    }
	};
	//weight
	$scope.weightSliderOptions = {
		showSelectionBar: false,
		floor: 40,
		ceil: 180,
		showSelectionBar: true,
		getSelectionBarColor: function (value) {
			return '#5cb85c';
		}
	};

	$scope.toggleDonated = function () {
		$scope.donor_log.donated = !$scope.donor_log.donated;
	};
	$scope.toggleProcessable = function () {
		$scope.donor_log.processable = !$scope.donor_log.processable;
	};


}])
.controller('EditDonorLogController', ['$scope', '$http', function ($scope, $http) {

	$scope.donor_log = gon.donor_log;
	// $scope.donor_log = {};
	// DonorLog.get({id: gon.donor_log_id});

	// DonorLog.get({id: gon.donor_log_id}, function (res) {
	// 	$scope.donor_log = res;
	// }, function (err) {
	// 	$scope.check = err;
	// });

	// watch donated
	$scope.$watch('donor_log.donated', function (newData) {
	  // $log.log(newData);
	  if (!newData && $scope.donor_log.processable) {
	    $scope.donor_log.processable = false;
	  }
	});
	//watch processable
	$scope.$watch('donor_log.processable', function (newData) {
	  // $log.log(newData);
	  if (newData && !$scope.donor_log.donated) {
	    $scope.donor_log.donated = true;
	  }
	});

		var colors = [
			'#5C2E00',
			'#703800',
			'#854200',
			'#9A4D00',
			'#AB5500',
			'#BC5D00',
			'#CD6600'
		];
		//bristol
		$scope.bristolSliderOptions = {
			floor: 1,
			ceil: 7,
			showSelectionBar: true,
	    getSelectionBarColor: function (value) {
	    	return colors[value-1];
	    }
		};
		//weight
		$scope.weightSliderOptions = {
			showSelectionBar: false,
			floor: 40,
			ceil: 180,
			showSelectionBar: true,
			getSelectionBarColor: function (value) {
				return '#5cb85c';
			}
		}
}])
;