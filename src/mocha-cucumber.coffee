mocha = require 'mocha-nightwatch'
reporter = require './reporter'

module.exports = (suite) ->
  mocha.interfaces.bdd suite

  suite.on "pre-require", (context, file, mocha) ->
    for clause in ['Feature', 'Scenario']
      do (clause) ->
        context[clause] = (title, fn) ->
          suite = context.describe title, ->
            # Register an after hook that runs at the end of each Scenario
            # block and causes the selenium client to be closed.
            after (client, done) ->
              client.end ->
                done();

            fn();
          suite.name = clause
          return suite

    for clause in ['Given', 'When', 'Then', 'And', 'But']
      do (clause) ->
        context[clause] = (title, fn) ->
          test = context.it title, fn
          test.name = clause
          return test

    mocha.reporter reporter
