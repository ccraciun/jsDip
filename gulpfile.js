/* jshint node:true */
'use strict';

var gulp = require('gulp');

/**
 * NOTE: Any node package named 'gulp-{name}' will show up
 * as plugins.{name}
 */
var plugins = require('gulp-load-plugins')();

var browserify = require('browserify');
var source = require('vinyl-source-stream');


gulp.task('browserify', function () {
  // TODO(rkofman): Remove source maps unless in DEV
  return browserify(
    {
     entries: ['./app/scripts/application.coffee'],
     extensions: ['.coffee', '.hbs'],
     debug: true
    })
    .bundle() // generates source maps.
    .pipe(source('application.js'))
    .pipe(gulp.dest('tmp/scripts'));
});

gulp.task('styles', function () {
  return gulp.src('app/styles/main.scss')
    .pipe(plugins.plumber())
    .pipe(plugins.rubySass({
      style: 'expanded',
      precision: 10
    }))
    .pipe(plugins.autoprefixer({browsers: ['last 1 version']}))
    .pipe(gulp.dest('tmp/styles'));
});

gulp.task('jshint', function () {
  return gulp.src('app/scripts/**/*.js')
    .pipe(plugins.jshint())
    .pipe(plugins.jshint.reporter('jshint-stylish'))
    .pipe(plugins.jshint.reporter('fail'));
});

// gulp.task('scripts', function(){
//   return gulp.src('app/scripts/**/*.coffee')
//     .pipe(plugins.sourcemaps.init())
//     .pipe(plugins.coffee()).on('error', plugins.util.log)
//     .pipe(plugins.sourcemaps.write('./maps'))
//     .pipe(gulp.dest('tmp/scripts'));
// });

gulp.task('html', ['styles', 'browserify'], function () {
  var assets = plugins.useref.assets({searchPath: '{tmp,app}'});

  return gulp.src('app/*.html')
    .pipe(assets)
    .pipe(plugins.if('*.js', plugins.uglify()))
    .pipe(plugins.if('*.css', plugins.csso()))
    .pipe(assets.restore())
    .pipe(plugins.useref())
    .pipe(plugins.if('*.html', plugins.minifyHtml({conditionals: true, loose: true})))
    .pipe(gulp.dest('dist'));
});

gulp.task('images', function () {
  return gulp.src('app/images/**/*')
    .pipe(plugins.cache(plugins.imagemin({
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest('dist/images'));
});

gulp.task('fonts', function () {
  return gulp.src(require('main-bower-files')().concat('app/fonts/**/*'))
    .pipe(plugins.filter('**/*.{eot,svg,ttf,woff}'))
    .pipe(plugins.flatten())
    .pipe(gulp.dest('dist/fonts'));
});

gulp.task('extras', function () {
  return gulp.src([
    'app/*.*',
    '!app/*.html',
    'node_modules/apache-server-configs/dist/.htaccess'
  ], {
    dot: true
  }).pipe(gulp.dest('dist'));
});

gulp.task('clean', require('del').bind(null, ['tmp', 'dist']));

gulp.task('connect', ['styles', 'browserify'], function () {
  var serveStatic = require('serve-static');
  var serveIndex = require('serve-index');
  var app = require('connect')()
    .use(require('connect-livereload')({port: 35729}))
    .use(serveStatic('tmp'))
    .use(serveStatic('app'))
    // paths to bower_components should be relative to the current file
    // e.g. in app/index.html you should use ../bower_components
    .use('/bower_components', serveStatic('bower_components'))
    .use(serveIndex('app'));

  require('http').createServer(app)
    .listen(9000)
    .on('listening', function () {
      console.log('Started connect web server on http://localhost:9000');
    });
});

gulp.task('serve', ['connect', 'watch'], function () {
  require('opn')('http://localhost:9000');
});

// inject bower components
gulp.task('wiredep', function () {
  var wiredep = require('wiredep').stream;

  gulp.src('app/styles/*.scss')
    .pipe(wiredep())
    .pipe(gulp.dest('app/styles'));

  gulp.src('app/*.html')
    .pipe(wiredep())
    .pipe(gulp.dest('app'));
});

gulp.task('watch', ['connect'], function () {
  plugins.livereload.listen();

  // watch for changes
  gulp.watch([
    'app/*.html',
    'tmp/styles/**/*.css',
    '{tmp,app}/scripts/**/*.js',
    'app/images/**/*'
  ]).on('change', plugins.livereload.changed);

  gulp.watch('app/styles/**/*.scss', ['styles']);
  gulp.watch('app/scripts/**/*.coffee', ['browserify']);
  gulp.watch('bower.json', ['wiredep']);
});

gulp.task('build', ['jshint', 'html', 'images', 'fonts', 'extras'], function () {
  return gulp.src('dist/**/*').pipe(plugins.size({title: 'build', gzip: true}));
});

gulp.task('default', ['clean'], function () {
  gulp.start('build');
});

gulp.task('test', function () {
    return gulp.src('test/spec/*.js', {read: false})
        .pipe(plugins.mocha({reporter: 'spec'}));
});
