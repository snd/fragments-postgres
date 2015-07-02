hinoki = require 'hinoki'

fragmentsPostgres = require '../src/fragments-postgres'

module.exports =

###################################################################################
# table

  'table':

    'userTable': (test) ->
      calls =
        table: []
      mesa = {}
      table = {}
      mesa.table = (arg) ->
        calls.table.push arg
        table

      lifetime =
        fragments_mesa: mesa

      hinoki(fragmentsPostgres, lifetime, 'fragments_userTable')
        .then (result) ->
          test.equal result, table
          test.deepEqual calls.table, ['user']
          test.done()

    'projectMessageTable': (test) ->
      calls =
        table: []
      mesa = {}
      table = {}
      mesa.table = (arg) ->
        calls.table.push arg
        table

      lifetime =
        fragments_mesa: mesa

      hinoki(fragmentsPostgres, lifetime, 'fragments_projectMessageTable')
        .then (result) ->
          test.equal result, table
          test.deepEqual calls.table, ['project_message']
          test.done()

###################################################################################
# select

  'parseSelect': (test) ->
    test.ok not fragmentsPostgres.parseSelect('fragments_first')
    test.ok not fragmentsPostgres.parseSelect('fragments_firstWithConnection')
    test.deepEqual fragmentsPostgres.parseSelect('fragments_firstUser'),
      type: 'first'
      table: 'user'
      order: []
      where: []
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('fragments_firstUserWithConnection'),
      type: 'first'
      table: 'user'
      order: []
      where: []
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('fragments_selectUserCreatedAt'),
      type: 'select'
      table: 'user_created_at'
      order: []
      where: []
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('fragments_selectUserCreatedAtWithConnection'),
      type: 'select'
      table: 'user_created_at'
      order: []
      where: []
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('fragments_firstUserWhereCreatedAt'),
      type: 'first'
      table: 'user'
      order: []
      where: ['created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('fragments_firstUserWhereCreatedAtWithConnection'),
      type: 'first'
      table: 'user'
      order: []
      where: ['created_at']
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('fragments_selectOrderReportWhereOrderIdWhereCreatedAt'),
      type: 'select'
      table: 'order_report'
      order: []
      where: ['order_id', 'created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('fragments_firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDesc'),
      type: 'first'
      table: 'order_report'
      order: [
        {
          column: 'created_at'
          direction: 'DESC'
        }
      ]
      where: ['order_id', 'created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('fragments_firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDescWithConnection'),
      type: 'first'
      table: 'order_report'
      order: [
        {
          column: 'created_at'
          direction: 'DESC'
        }
      ]
      where: ['order_id', 'created_at']
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('fragments_selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAsc'),
      type: 'select'
      table: 'order_report'
      order: [
        {
          column: 'created_at'
          direction: 'ASC'
        }
        {
          column: 'id'
          direction: 'DESC'
        }
        {
          column: 'report_number'
          direction: 'ASC'
        }
      ]
      where: ['order_id', 'created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('fragments_selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAscWithConnection'),
      type: 'select'
      table: 'order_report'
      order: [
        {
          column: 'created_at'
          direction: 'ASC'
        }
        {
          column: 'id'
          direction: 'DESC'
        }
        {
          column: 'report_number'
          direction: 'ASC'
        }
      ]
      where: ['order_id', 'created_at']
      withConnection: true

    test.done()

  'first':

    'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrder': (test) ->
      calls =
        where: []
        order: []
      table = {}
      result = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.order = (arg) ->
        calls.order.push arg
        table
      table.first = ->
        result

      lifetime =
        userTable: table

      hinoki(fragmentsPostgres, lifetime, 'fragments_firstUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrder')
        .then (accessor) ->
          test.equal result, accessor 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.deepEqual calls.order, ['updated_at DESC, order ASC']
          test.done()

    'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrderWithConnection': (test) ->
      calls =
        where: []
        order: []
      table = {}
      result = {}
      connection = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.order = (arg) ->
        calls.order.push arg
        table
      table.setConnection = (arg) ->
        test.equal arg, connection
        table
      table.first = ->
        result

      lifetime =
        userTable: table

      hinoki(fragmentsPostgres, lifetime, 'fragments_firstUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrderWithConnection')
        .then (accessor) ->
          test.equal result, accessor 1, 2, connection
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.deepEqual calls.order, ['updated_at DESC, order ASC']
          test.done()

  'select':

    'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrder': (test) ->
      calls =
        where: []
        order: []
      table = {}
      result = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.order = (arg) ->
        calls.order.push arg
        table
      table.find = ->
        result

      lifetime =
        userTable: table

      hinoki(fragmentsPostgres, lifetime, 'fragments_selectUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrder')
        .then (accessor) ->
          test.equal result, accessor 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.deepEqual calls.order, ['updated_at DESC, order ASC']
          test.done()

    'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrderWithConnection': (test) ->
      calls =
        where: []
        order: []
      table = {}
      result = {}
      connection = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.order = (arg) ->
        calls.order.push arg
        table
      table.setConnection = (arg) ->
        test.equal arg, connection
        table
      table.find = ->
        result

      lifetime =
        userTable: table

      hinoki(fragmentsPostgres, lifetime, 'fragments_selectUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrderWithConnection')
        .then (accessor) ->
          test.equal result, accessor 1, 2, connection
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.deepEqual calls.order, ['updated_at DESC, order ASC']
          test.done()

###################################################################################
# insert

  'parseInsert': (test) ->
    test.ok not fragmentsPostgres.parseInsert('fragments_insert')
    test.ok not fragmentsPostgres.parseInsert('fragments_insertWithConnection')
    test.deepEqual fragmentsPostgres.parseInsert('fragments_insertOrderReport'),
      table: 'order_report'
      withConnection: false
    test.deepEqual fragmentsPostgres.parseInsert('fragments_insertUserWhere'),
      table: 'user_where'
      withConnection: false
    test.deepEqual fragmentsPostgres.parseInsert('fragments_insertUserWhereWithConnection'),
      table: 'user_where'
      withConnection: true

    test.done()

  'insert':

    'insertUser': (test) ->
      test.expect 3
      result = {}
      data = {}
      allowedColumns = {}
      table = {}
      table.allow = (arg) ->
        test.equal arg, allowedColumns
        table
      table.insert = (arg) ->
        test.equal arg, data
        result

      lifetime =
        userTable: table
        userInsertableColumns: allowedColumns

      hinoki(fragmentsPostgres, lifetime, 'fragments_insertUser')
        .then (accessor) ->
          test.equal result, accessor data
          test.done()

    'insertUserWithConnection': (test) ->
      test.expect 4
      result = {}
      data = {}
      allowedColumns = {}
      connection = {}
      table = {}
      table.allow = (arg) ->
        test.equal arg, allowedColumns
        table
      table.insert = (arg) ->
        test.equal arg, data
        result
      table.setConnection = (arg) ->
        test.equal arg, connection
        table

      lifetime =
        userTable: table
        userInsertableColumns: allowedColumns

      hinoki(fragmentsPostgres, lifetime, 'fragments_insertUserWithConnection')
        .then (accessor) ->
          test.equal result, accessor data, connection
          test.done()

###################################################################################
# update

  'parseUpdate': (test) ->
    test.ok not fragmentsPostgres.parseUpdate('fragments_update')
    test.ok not fragmentsPostgres.parseUpdate('fragments_updateWithConnection')
    test.ok not fragmentsPostgres.parseUpdate('fragments_updateOrderReport')?
    test.deepEqual fragmentsPostgres.parseUpdate('fragments_updateOrderReportWhereRegistrationNumber'),
      table: 'order_report'
      where: ['registration_number']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseUpdate('fragments_updateOrderReportWhereRegistrationNumberWithConnection'),
      table: 'order_report'
      where: ['registration_number']
      withConnection: true

    test.done()

  'update':

    'updateUserWhereIdWhereCreatedAt': (test) ->
      calls =
        where: []
      result = {}
      data = {}
      allowedColumns = {}
      table = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.allow = (arg) ->
        test.equal arg, allowedColumns
        table
      table.update = (arg) ->
        test.equal arg, data
        result

      lifetime =
        userTable: table
        userUpdateableColumns: allowedColumns

      hinoki(fragmentsPostgres, lifetime, 'fragments_updateUserWhereIdWhereCreatedAt')
        .then (accessor) ->
          test.equal result, accessor data, 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.done()


    'updateUserWhereIdWhereCreatedAtWithConnection': (test) ->
      calls =
        where: []
      result = {}
      data = {}
      allowedColumns = {}
      connection = {}
      table = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.allow = (arg) ->
        test.equal arg, allowedColumns
        table
      table.setConnection = (arg) ->
        test.equal arg, connection
        table
      table.update = (arg) ->
        test.equal arg, data
        result

      lifetime =
        userTable: table
        userUpdateableColumns: allowedColumns

      hinoki(fragmentsPostgres, lifetime, 'fragments_updateUserWhereIdWhereCreatedAt')
        .then (accessor) ->
          test.equal result, accessor data, 1, 2, connection
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.done()

###################################################################################
# delete

  'parseDelete': (test) ->
    test.ok not fragmentsPostgres.parseDelete('fragments_delete')
    test.ok not fragmentsPostgres.parseDelete('fragments_deleteWithConnection')
    test.ok not fragmentsPostgres.parseDelete('fragments_deleteOrderReport')?
    test.deepEqual fragmentsPostgres.parseDelete('fragments_deleteOrderReportWhereOrderId'),
      table: 'order_report'
      where: ['order_id']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseDelete('fragments_deleteOrderReportWhereOrderIdWithConnection'),
      table: 'order_report'
      where: ['order_id']
      withConnection: true

    test.done()

  'delete':

    'deleteUserWhereIdWhereCreatedAt': (test) ->
      calls =
        where: []
      table = {}
      result = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.delete = ->
        result

      lifetime =
        userTable: table

      hinoki(fragmentsPostgres, lifetime, 'fragments_deleteUserWhereIdWhereCreatedAt')
        .then (accessor) ->
          test.equal result, accessor 1, 2
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.done()

    'deleteUserWhereIdWhereCreatedAtWithConnection': (test) ->
      calls =
        where: []
      table = {}
      result = {}
      connection = {}
      table.where = (arg) ->
        calls.where.push arg
        table
      table.setConnection = (arg) ->
        test.equal arg, connection
        table
      table.delete = ->
        result

      lifetime =
        userTable: table

      hinoki(fragmentsPostgres, lifetime, 'fragments_deleteUserWhereIdWhereCreatedAtWithConnection')
        .then (accessor) ->
          test.equal result, accessor 1, 2, connection
          test.deepEqual calls.where, [
            {id: 1}
            {created_at: 2}
          ]
          test.done()
