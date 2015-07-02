hinoki = require 'hinoki'

sources = require './sources'

factories = hinoki.source(__dirname + '/factories')

module.exports = hinoki.source([
  factories
  sources.table
  sources.selectFirst
  sources.select
  sources.insert
  sources.update
  sources.delete
])

module.exports.factoriesSource = factories

Object.keys(sources).map (key) ->
  module.exports[key] = sources[key]
