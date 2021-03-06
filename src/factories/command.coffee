module.exports.command_pg_migrate = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgMigrate
    fragments_shutdown
    fragments_Promise
  ) ->
    (args...) ->
      isVerbose = '--verbose' in args
      isDry = '--dry'in args

      fragments_pgMigrate(isVerbose, isDry)
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
module.exports.command_pg_migrate.__help = '[--verbose] [--dry] - migrate: apply all migrations in directory that is in envvar `MIGRATION_PATH` to database whose url is in envvar `DATABASE_URL`'

module.exports.command_migrations_create = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_fs
    fragments_path
    fragments_moment
    fragments_config_migrationPath
    fragments_Promise
  ) ->
    (name) ->
      unless name?
        fragments_console.log 'Usage: ... migrations:create {migration-name}'
        return

      time = fragments_moment().format('YYYYMMDDHHmmss')
      filename = "#{time}-#{name}.sql"
      filepath = fragments_path.join(fragments_config_migrationPath, filename)
      fragments_console.log(filepath)

      # make sure the migration path is present
      fragments_fs.mkdirAsync(fragments_config_migrationPath)
        .catch (err) ->
          if err.cause.code isnt 'EEXIST'
            fragments_Promise.reject err
        .then ->
          fragments_fs.writeFileAsync(filepath, '')
        .then ->
          fragments_console.log 'OK'
module.exports.command_migrations_create.__help = '{migration-name} - create a new migration in directory that is in envvar `MIGRATION_PATH`'

module.exports.command_pg_create = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgCreate
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgCreate()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
module.exports.command_pg_create.__help = '- create database whose name is in envvar `POSTGRES_DATABASE`'

module.exports.command_pg_drop = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgDrop
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgDrop()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
module.exports.command_pg_drop.__help = '- drop database whose name is in envvar `POSTGRES_DATABASE`'

module.exports.command_pg_dropCreate = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgDropCreate
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgDropCreate()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
module.exports.command_pg_dropCreate.__help = '- drop and then create database whose name is in in envvar `POSTGRES_DATABASE`'

module.exports.command_pg_dropCreateMigrate = (
  fragments_APPLICATION
) ->
  fragments_APPLICATION (
    fragments_console
    fragments_pgDropCreateMigrate
    fragments_shutdown
    fragments_Promise
  ) ->
    ->
      fragments_pgDropCreateMigrate()
        .catch (err) ->
          fragments_console.log 'shutting down because of error:', err
          fragments_shutdown().then ->
            fragments_Promise.reject err
        .then ->
          fragments_shutdown()
        .then ->
          fragments_console.log 'OK'
module.exports.command_pg_dropCreateMigrate.__help = '- drop and then create database whose name is in in envvar `POSTGRES_DATABASE` and then apply all migrations in directory that is in envvar `MIGRATION_PATH` to database whose url is in envvar `DATABASE_URL`'
