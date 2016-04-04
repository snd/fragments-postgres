module.exports.fragments_pgMigrate = (
  fragments_Promise
  fragments_lodash
  fragments_console
  fragments_config_migrationPath
  fragments_config_databaseUrl
  fragments_insertSchemaInfoTableIfNotExists
  fragments_selectMigrations
  fragments_applyMigration
  fragments_readMigrationDir
) ->
  (isVerbose = false, isDry = false) ->
    _ = fragments_lodash

    fragments_readMigrationDir().then (migrations) ->

      if isVerbose
        fragments_console.log "fragments_config_migrationPath =", fragments_config_migrationPath
        fragments_console.log "fragments_config_databaseUrl =", fragments_config_databaseUrl
        fragments_console.log "migrations =", migrations

      fragments_insertSchemaInfoTableIfNotExists()
        .then ->
          fragments_selectMigrations()
        .then (appliedMigrations) ->
          notAppliedMigrations = _.difference migrations, appliedMigrations
          if isVerbose
            fragments_console.log "already applied =", appliedMigrations

          fragments_console.log "about to apply =", notAppliedMigrations

          if isDry
            return

          reducer = (soFar, m) ->
            soFar.then ->
              fragments_console.log "applying", m
              fragments_applyMigration m

          notAppliedMigrations.reduce reducer, fragments_Promise.resolve()

module.exports.fragments_getFileExtension = (fragments_path) ->
  (filename) ->
    ext = fragments_path.extname(filename||'').split('.')
    ext[ext.length - 1]

module.exports.fragments_insertSchemaInfoTableIfNotExists = (
  fragments_mesa
) ->
  ->
    fragments_mesa.query "CREATE TABLE IF NOT EXISTS schema_info (migration text NOT NULL)"

module.exports.fragments_selectMigrations = (
  fragments_lodash
  fragments_mesa
) ->
  ->
    fragments_mesa.table('schema_info').find().then (schemaInfo) ->
      fragments_lodash.map schemaInfo, 'migration'

module.exports.fragments_applyMigration = (
  mesa
  fragments_readMigrationFile
) ->
  (migrationFileName) ->
    fragments_readMigrationFile(migrationFileName).then (migrationSql) ->
      mesa.wrapInTransaction (connection) ->
        transaction = mesa.setConnection(connection)
        transaction.query(migrationSql).then ->
          transaction
            .table('schema_info')
            .unsafe()
            .insert({migration: migrationFileName})

module.exports.fragments_readMigrationDir = (
  fragments_fs
  fragments_config_migrationPath
  fragments_getFileExtension
) ->
  ->
    fragments_fs.readdirAsync(fragments_config_migrationPath).then (files) ->
      files.filter (file) ->
        'sql' is fragments_getFileExtension file

module.exports.fragments_readMigrationFile = (
  fragments_fs
  fragments_path
  fragments_config_migrationPath
) ->
  (name) ->
    path = fragments_path.join(fragments_config_migrationPath, name)
    fragments_fs.readFileAsync path, 'utf-8'

################################################################################
# database

module.exports.fragments_pgCreate = (
  fragments_childProcess
  fragments_config_postgresDatabase
  fragments_console
) ->
  ->
    fragments_console.log 'createDatabase', fragments_config_postgresDatabase
    fragments_childProcess.execAsync "createdb #{fragments_config_postgresDatabase}"

module.exports.fragments_pgDrop = (
  fragments_childProcess
  fragments_config_postgresDatabase
  fragments_console
) ->
  ->
    fragments_console.log 'dropDatabase', fragments_config_postgresDatabase
    fragments_childProcess.execAsync "dropdb --if-exists #{fragments_config_postgresDatabase}"

module.exports.fragments_pgDropCreate =(
  fragments_pgDrop
  fragments_pgCreate
) ->
  ->
    fragments_pgDrop().then ->
      fragments_pgCreate()

module.exports.fragments_pgDropCreateMigrate =(
  fragments_pgDropCreate
  fragments_pgMigrate
) ->
  ->
    fragments_pgDropCreate().then ->
      fragments_pgMigrate()
