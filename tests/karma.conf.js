module.exports = function(karma) {
	karma.set({

// base path, that will be used to resolve files and exclude
basePath: '../',

// Start these browsers, currently available:
// - PhantomJS
// - Chrome, ChromeCanary
// - Firefox, Opera
// - Safari (only Mac)
// - IE (only Windows)
browsers: ['Chrome'],

frameworks: ['mocha', 'sinon-chai'],

// list of files / patterns to load in the browser
files: [
	// Program files
	'public/vendor.js',
	'public/app.js',
	// Specs
	'tests/test-*.coffee'
],

// list of files to exclude
exclude: [],

// Plugins to load
preprocessors: {
	'**/*.coffee': 'coffee'
},

// report which specs are slower than 500ms
// CLI --report-slower-than 500
reportSlowerThan: 500,

// test results reporter to use
// possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
reporters: ['progress'],

// enable / disable colors in the output (reporters and logs)
colors: true,

// enable / disable watching file and executing tests whenever any file changes
autoWatch: true,

// Continuous Integration mode
// if true, it capture browsers, run tests and exit
singleRun: false,

// level of logging
// possible values:
// - karma.LOG_DISABLE
// - karma.LOG_ERROR
// - karma.LOG_WARN
// - karma.LOG_INFO
// - karma.LOG_DEBUG
logLevel: karma.LOG_INFO,

// web server port
port: 9876,

// cli runner port
runnerPort: 9100,

// If browser does not capture in given timeout [ms], kill it
captureTimeout: 5000

	});
};