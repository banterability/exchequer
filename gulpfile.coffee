browserSync = require 'browser-sync'
gulp = require 'gulp'
nib = require 'nib'
stylus = require 'gulp-stylus'

reload = browserSync.reload

gulp.task 'reload', -> reload()

gulp.task 'stylus', ->
  gulp.src 'assets/stylus/*.styl'
    .pipe stylus
      use: nib()
      compress: true
    .pipe gulp.dest 'public'
    .pipe reload stream: true

gulp.task 'server', ->
  browserSync server:
    baseDir: './'

gulp.task 'default', ['stylus', 'server'], ->
  gulp.watch 'assets/stylus/*.styl', ['stylus']
  gulp.watch 'index.html', ['reload']
