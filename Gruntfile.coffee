module.exports = (grunt) ->

  grunt.initConfig

    watch:
      sass:
        files: 'app/style/**/*.sass'
        tasks: ['sass']
      coffee:
        files: 'app/**/*.coffee'
        tasks: ['browserify']
      html:
        files: 'app/index.html'
        tasks: ['copy:html']

    sass:
      dev:
        files:
          'public/style.css': 'app/style/main.sass'

    browserify:
      dev:
        files:
          'public/main.js': ['app/main.coffee']
        options:
          browserifyOptions:
            extensions: [".coffee"]
            fullPaths: false
            debug: true
          transform: ["coffeeify"]

    copy:
      html:
        src: 'app/index.html'
        dest: 'public/index.html'
        nonull: true

    browserSync:
      dev:
        bsFiles:
          src: './public'
        options:
          watchTask: true,
          server: './public'

    coffee:
      release:
        files:
          'dist/carousel.js': 'app/util/carousel.coffee'

  grunt.loadNpmTasks 'grunt-contrib-sass'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-browser-sync'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  grunt.registerTask 'build', ['copy:html', 'sass', 'browserify']
  grunt.registerTask 'release', ['coffee:release']
  grunt.registerTask 'default', ['build', 'browserSync', 'watch']