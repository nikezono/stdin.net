'use strict'

module.exports = (grunt) ->

  _ = require 'underscore'
  require 'coffee-errors'

  # ユーティリティ系
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-notify'
  # ドキュメント系
  grunt.loadNpmTasks 'grunt-apidoc'
  grunt.loadNpmTasks 'grunt-docco-dir'
  # テスト系
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-mocha-test'
  # カバレッジ系
  grunt.loadNpmTasks 'grunt-istanbul'

  grunt.registerTask 'test',     [ 'coffeelint','coffee','mochaTest:spec' ]
  grunt.registerTask 'coverage', [ 'clean','coffee','copy', 'instrument', 'mochaTest:coverage', 'storeCoverage', 'makeReport']
  grunt.registerTask 'travis',   [ 'coverage']
  grunt.registerTask 'default',  [ 'test', 'watch' ]

  grunt.initConfig

    coffeelint:
      options:
        max_line_length:
          value: 130
        indentation:
          value: 2
        newlines_after_classes:
          level: 'error'
        no_empty_param_list:
          level: 'error'
        no_unnecessary_fat_arrows:
          level: 'ignore'
      dist:
        files: [
          { expand: yes, cwd: 'test/', src: [ '*.coffee' ] }
          { expand: yes, cwd: './', src: [ '*.coffee' ] }
          { expand: yes, cwd: 'models/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'config/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'crowler/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'events/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'routes/', src: [ '**/*.coffee' ] }
          { expand: yes, cwd: 'assets/', src: [ '**/*.coffee' ] }
        ]

    watch:
      options:
        interrupt: yes
      dist:
        files: [
          '*.coffee'
          'models/**/*.coffee'
          'events/**/*.coffee'
          'config/**/*.coffee'
          'routes/**/*.coffee'
          'crowler/**/*.coffee'
          'views/**/*.jade'
          'assets/**//*.coffee'
          'test/**/*.coffee'
        ]
        tasks: [ 'clean:docs','docco','apidoc','coffeelint','coffee','mochaTest:spec' ]

    coffee:
      clientjs:
        expand:true
        cwd:'assets/coffee'
        src:'*.coffee'
        dest:'public/js/'
        ext:'.js'
      # @todo ビルド
      build:
        expand:true
        cwd:''
        src:'server.coffee'
        dest:'build/'
        ext:'.js'

    copy:
      coverage:
        files: [
          expand: true
          src: ['test/*']
          dest: 'coverage/instrument/'
        ]

    clean:
      coverage:
        src: ['coverage/']
      build:
        src: ['build/']
      docs:
        src:["public/docs/","public/apidocs"]

    # Doc
    docco:
      debug:
        src: [
          '*.coffee'
          'models/**/*.coffee'
          'events/**/*.coffee'
          'config/**/*.coffee'
          'routes/**/*.coffee'
          'crowler/**/*.coffee'
          'assets/**/*.coffee'
          'test/**/*.coffee'
        ]
        options:
          output: 'public/docs/'

    apidoc:
      app:
        src:"events/"
        dest:"public/apidocs/"

    # Istanbul(MochaTest+Coverage Report)
    instrument:
      files: "build/*.js"
      options:
        lazy: true
        basePath: "coverage/instrument/"

    mochaTest:
      spec:
        options:
          reporter:"spec"
          timeout: 50000
          colors: true
        src: ['test/**/*.coffee']
      coverage:
        options:
          reporter:"spec"
          timeout: 50000
          colors:true
        src: ['coverage/instrument/test/*.coffee']

    storeCoverage:
      options:
        dir: "coverage/reports"

    makeReport:
      src: "coverage/reports/**/*.json"
      options:
        type: "lcov"
        dir: "coverage/reports"
        print: "detail"
