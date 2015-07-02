helfer = require 'helfer'

optionsToConfig = (options) ->
  config = {}

  config.keyPrefix = 'fragments_'

  # TODO better name for this
  config.tableWordArray =
    helfer.splitCamelcase (options.tableWords or 'table')

  config.tableToKey = options.tableToKey or (tableName) ->
    words = helfer.splitUnderscore(tableName).concat(config.tableWordArray)
    helfer.joinCamelcase words

  config.tableToInsertableColumns = options.tableToInsertableColumns or (table) ->
    helfer.snakeToCamel(table) + 'InsertableColumns'

  config.tableToUpdateableColumns = options.tableToUpdateableColumns or (table) ->
    helfer.snakeToCamel(table) + 'UpdateableColumns'

  config.stripPrefix = (string) ->
    if 0 isnt string.indexOf(config.keyPrefix)
      return
    string.slice(config.keyPrefix.length)

  return config

configure = (options = {}) ->
  config = optionsToConfig options
  sources = {}

###################################################################################
# table

  sources.table = (key) ->
    key = config.stripPrefix key
    unless key?
      return

    words = helfer.splitCamelcase key

    results = helfer.splitArrayWhereSequence words, config.tableWordArray

    containsTable = results.length is 2
    unless containsTable
      return
    doesntBeginWithTable = results[0]?.length isnt 0
    unless doesntBeginWithTable
      return
    endsWithTable = results[1]?.length is 0
    unless endsWithTable
      return

    tableName = helfer.joinUnderscore results[0]

    factory = (fragments_mesa) ->
      fragments_mesa.table(tableName)

    factory.__inject = ['fragments_mesa']
    factory.__source = 'generated by fragments-postgres.table'
    return factory


###################################################################################
# parse data select

  sources.parseSelect = (key) ->
    key = config.stripPrefix key
    unless key?
      return

    words = helfer.splitCamelcase key

    type = words[0]

    unless type in ['first', 'select']
      return

    tableWhereOrderConnection = words.slice(1)

    [tableWhereOrder, withConnection] = helfer.splitArrayWhereSequence(
      tableWhereOrderConnection
      ['with', 'connection']
    )

    [tableWhere, order...] = helfer.splitArrayWhereSequence(
      tableWhereOrder
      ['order', 'by']
    )

    [table, where...] = helfer.splitArrayWhereSequence tableWhere, 'where'

    if table.length is 0
      return

    whereProcessed = where
      .filter (x) -> x.length isnt 0
      .map helfer.joinUnderscore

    orderProcessed = order
      .filter (x) -> x.length isnt 0
      .map (x) ->
        last = x[x.length - 1]
        if last in ['asc', 'desc']
          column = x.slice(0, -1)
          direction = last.toUpperCase()
        else
          column = x
          direction = 'ASC'
        {
          column: helfer.joinUnderscore column
          direction: direction
        }

    {
      type: type
      table: helfer.joinUnderscore table
      order: orderProcessed
      where: whereProcessed
      withConnection: withConnection?
    }

###################################################################################
# select first

  sources.selectFirst = (key) ->
    parsed = sources.parseSelect key
    unless parsed? and parsed.type is 'first'
      return

    factory = (table) ->
      (args...) ->
        query = table
        index = 0
        parsed.where.forEach (x) ->
          condition = {}
          condition[x] = args[index++]
          query = query.where condition
        if parsed.order.length isnt 0
          order = parsed.order
            .map (x) ->
              x.column + ' ' + x.direction
            .join (', ')
          query = query.order order
        if parsed.withConnection
          connection = args[index]
          unless connection?
            throw new Error "#{key} must be called with connection as argument number #{index+1}"
          query = query.setConnection connection

        query.first()

    factory.__inject = [
      config.tableToKey(parsed.table)
    ]
    factory.__source = 'generated by fragments-postgres.selectFirst'
    factory.__parsed = parsed
    return factory

###################################################################################
# select

  sources.select = (key) ->
    parsed = sources.parseSelect key
    unless parsed? and parsed.type is 'select'
      return

    factory = (table) ->
      (args...) ->
        q = table
        index = 0
        parsed.where.forEach (x) ->
          condition = {}
          condition[x] = args[index++]
          q = q.where condition
        if parsed.order.length isnt 0
          order = parsed.order
            .map (x) ->
              x.column + ' ' + x.direction
            .join (', ')
          q = q.order order
        if parsed.withConnection
          connection = args[index]
          unless connection?
            throw new Error "#{key} must be called with connection as argument number #{index+1}"
          q = q.setConnection connection
        q.find()

    factory.__inject = [
      config.tableToKey(parsed.table)
    ]
    factory.__source = 'generated by fragments-postgres.select'
    factory.__parsed = parsed
    return factory

###################################################################################
# insert

  sources.parseInsert = (key) ->
    key = config.stripPrefix key
    unless key?
      return

    words = helfer.splitCamelcase key

    unless 'insert' is words[0]
      return

    [table, withConnection] = helfer.splitArrayWhereSequence(
      words.slice(1)
      ['with', 'connection']
    )

    if table.length is 0
      return

    {
      table: helfer.joinUnderscore(table)
      withConnection: withConnection?
    }

  sources.insert = (key) ->
    parsed = sources.parseInsert key
    unless parsed?
      return

    factory = (table, allowedColumns) ->
      (data, args...) ->
        query = table
        index = 0
        if parsed.withConnection
          connection = args[index]
          unless connection?
            throw new Error "#{key} must be called with connection as argument number #{index+1}"
          query = query.setConnection connection
        query
          .allow(allowedColumns)
          .insert(data)

    factory.__inject = [
      config.tableToKey(parsed.table)
      config.tableToInsertableColumns(parsed.table)
    ]
    factory.__source = 'generated by fragments-postgres.insert'
    factory.__parsed = parsed
    return factory

###################################################################################
# update

  sources.parseUpdate = (key) ->
    key = config.stripPrefix key
    unless key?
      return

    words = helfer.splitCamelcase key

    unless 'update' is words[0]
      return

    [tableWhere, withConnection] = helfer.splitArrayWhereSequence(
      words.slice(1)
      ['with', 'connection']
    )

    [table, where...] = helfer.splitArrayWhereSequence tableWhere, 'where'

    if table.length is 0
      return

    # dont allow mass update without condition for security reasons
    if where.length is 0
      return

    {
      table: helfer.joinUnderscore(table)
      where: where.map (x) -> helfer.joinUnderscore x
      withConnection: withConnection?
    }

  sources.update = (key) ->
    parsed = sources.parseUpdate key
    unless parsed?
      return

    factory = (table, allowedColumns) ->
      (data, args...) ->
        query = table
        index = 0
        parsed.where.forEach (x) ->
          condition = {}
          condition[x] = args[index++]
          query = query.where condition
        if parsed.withConnection
          connection = args[index]
          unless connection?
            throw new Error "#{name} must be called with connection as argument number #{index+1}"
          query = query.setConnection connection
        query
          .allow(allowedColumns)
          .update(data)

    factory.__inject = [
      config.tableToKey(parsed.table)
      config.tableToUpdateableColumns(parsed.table)
    ]
    factory.__source = 'generated by fragments-postgres.update'
    factory.__parsed = parsed
    return factory

###################################################################################
# delete

  sources.parseDelete = (key) ->
    key = config.stripPrefix key
    unless key?
      return

    words = helfer.splitCamelcase key

    unless 'delete' is words[0]
      return

    [tableWhere, withConnection] = helfer.splitArrayWhereSequence(
      words.slice(1)
      ['with', 'connection']
    )

    [table, where...] = helfer.splitArrayWhereSequence tableWhere, 'where'

    if table.length is 0
      return

    # dont allow mass update without condition for security reasons
    if where.length is 0
      return

    {
      table: helfer.joinUnderscore(table)
      where: where.map (x) -> helfer.joinUnderscore x
      withConnection: withConnection?
    }

  sources.delete = (key) ->
    parsed = sources.parseDelete key
    unless parsed?
      return

    factory = (table) ->
      (args...) ->
        query = table
        index = 0
        parsed.where.forEach (x) ->
          condition = {}
          condition[x] = args[index++]
          query = query.where condition
        if parsed.withConnection
          connection = args[index]
          unless connection?
            throw new Error "#{name} must be called with connection as argument number #{index+1}"
          query = query.setConnection connection
        query.delete()

    factory.__inject = [
      config.tableToKey(parsed.table)
    ]
    factory.__source = 'generated by fragments-postgres.delete'
    factory.__parsed = parsed
    return factory

  return sources

module.exports = configure()
module.exports.configure = configure
