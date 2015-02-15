var gulp = require('gulp');
var mocha = require('gulp-mocha');

gulp.task('default', function () {
    return gulp.src('spec/*.js', {read: false})
        .pipe(mocha({reporter: 'nyan'}));
});
