module.exports.fragments_pg = (
  fragments_Promise
  fragments_config_postgresPoolSize
  fragments_config_databaseUrl
  fragments_onShutdown
  fragments_pgDestroyPool
) ->
  pg = require 'pg'
  pg.defaults.poolSize = fragments_config_postgresPoolSize
  # https://github.com/brianc/node-postgres/wiki/pg#pgdefaultsparseint8
  pg.defaults.parseInt8 = true
  fragments_onShutdown 'postgres', ->
    fragments_pgDestroyPool pg, fragments_config_databaseUrl
  return pg

module.exports.fragments_mesa = (
  fragments_config_databaseUrl
  fragments_pg
) ->
  require('mesa').setConnection (cb) ->
    fragments_pg.connect fragments_config_databaseUrl, cb

module.exports.fragments_pgDestroyPool = (
  fragments_console
  fragments_Promise
) ->
  (pg, databaseUrl) ->
    poolKey = JSON.stringify(databaseUrl)
    fragments_console.log 'destroyPostgresPool'
    fragments_console.log 'Object.keys(pg.pools.all)', Object.keys(pg.pools.all)
    fragments_console.log 'poolKey', poolKey
    pool = pg.pools.all[poolKey]
    fragments_console.log 'pool?', pool?
    if pool?
      new fragments_Promise (resolve, reject) ->
        pool.drain ->
          # https://github.com/coopernurse/node-pool#step-3---drain-pool-during-shutdown-optional
          pool.destroyAllNow ->
            delete pg.pools.all[poolKey]
            resolve()
    else
      fragments_Promise.resolve()
