mocha = require 'mocha-nightwatch'
reporter = require './reporter'

toObject = (keys, values) ->
  return {} unless keys
  result = {}
  (if values then result[k] = values[i] else result) for k, i in keys
  result

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
        keys = examples[0]
        for exampleValues in examples[1..]
          example = toObject(keys, exampleValues)
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
