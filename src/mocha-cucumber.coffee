mocha = require 'mocha-nightwatch'
reporter = require './reporter'

module.exports = (suite) ->
  mocha.interfaces.bdd suite

  suite.on "pre-require", (context, file, mocha) ->
    context.Feature = (title, fn) ->
      suite = context.describe title, ->
        # Register an after hook that runs at the end of each Scenario
        # block and causes the selenium client to be closed.
        after (client, done) ->
          client.end ->
            done();

        fn();
      suite.name = 'Feature'
      return suite

    context.Scenario = (title, fn) ->
      suite = context.describe title, fn
      suite.name = 'Scenario'
      return suite

    context.ScenarioOutline = (title, fn, examples) ->
      suite = context.describe title, ->
        for example in examples
          innerSuite = context.describe JSON.stringify(example), ->
            fn(example);
          innerSuite.name = 'Example'
      suite.name = 'Scenario Outline'
      return suite

    for clause in ['Given', 'When', 'Then', 'And', 'But']
      do (clause) ->
        context[clause] = (title, fn) ->
          test = context.it title, fn
          test.name = clause
          return test

    mocha.reporter reporter
