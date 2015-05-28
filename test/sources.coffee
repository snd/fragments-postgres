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
        mesa: mesa

      hinoki(fragmentsPostgres, lifetime, 'userTable')
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
        mesa: mesa

      hinoki(fragmentsPostgres, lifetime, 'projectMessageTable')
        .then (result) ->
          test.equal result, table
          test.deepEqual calls.table, ['project_message']
          test.done()

###################################################################################
# select

  'parseSelect': (test) ->
    test.ok not fragmentsPostgres.parseSelect('first')
    test.ok not fragmentsPostgres.parseSelect('firstWithConnection')
    test.deepEqual fragmentsPostgres.parseSelect('firstUser'),
      type: 'first'
      name: 'user'
      order: []
      where: []
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('firstUserWithConnection'),
      type: 'first'
      name: 'user'
      order: []
      where: []
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('selectUserCreatedAt'),
      type: 'select'
      name: 'userCreatedAt'
      order: []
      where: []
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('selectUserCreatedAtWithConnection'),
      type: 'select'
      name: 'userCreatedAt'
      order: []
      where: []
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('firstUserWhereCreatedAt'),
      type: 'first'
      name: 'user'
      order: []
      where: ['created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('firstUserWhereCreatedAtWithConnection'),
      type: 'first'
      name: 'user'
      order: []
      where: ['created_at']
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('selectOrderReportWhereOrderIdWhereCreatedAt'),
      type: 'select'
      name: 'orderReport'
      order: []
      where: ['order_id', 'created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDesc'),
      type: 'first'
      name: 'orderReport'
      order: [
        {
          column: 'created_at'
          direction: 'DESC'
        }
      ]
      where: ['order_id', 'created_at']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseSelect('firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDescWithConnection'),
      type: 'first'
      name: 'orderReport'
      order: [
        {
          column: 'created_at'
          direction: 'DESC'
        }
      ]
      where: ['order_id', 'created_at']
      withConnection: true
    test.deepEqual fragmentsPostgres.parseSelect('selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAsc'),
      type: 'select'
      name: 'orderReport'
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
    test.deepEqual fragmentsPostgres.parseSelect('selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAscWithConnection'),
      type: 'select'
      name: 'orderReport'
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

      hinoki(fragmentsPostgres, lifetime, 'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrder')
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

      hinoki(fragmentsPostgres, lifetime, 'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrderWithConnection')
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

      hinoki(fragmentsPostgres, lifetime, 'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrder')
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

      hinoki(fragmentsPostgres, lifetime, 'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrderWithConnection')
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
    test.ok not fragmentsPostgres.parseInsert('insert')
    test.ok not fragmentsPostgres.parseInsert('insertWithConnection')
    test.deepEqual fragmentsPostgres.parseInsert('insertOrderReport'),
      name: 'orderReport'
      withConnection: false
    test.deepEqual fragmentsPostgres.parseInsert('insertUserWhere'),
      name: 'userWhere'
      withConnection: false
    test.deepEqual fragmentsPostgres.parseInsert('insertUserWhereWithConnection'),
      name: 'userWhere'
      withConnection: true

    test.done()

#   'newDataInsertResolver':
#
#     'insertUser': (test) ->
#       test.expect 3
#       result = {}
#       data = {}
#       allowedColumns = {}
#       table = {}
#       table.allow = (arg) ->
#         test.equal arg, allowedColumns
#         table
#       table.insert = (arg) ->
#         test.equal arg, data
#         result
#
#       container =
#         values:
#           userTable: table
#           userInsertableColumns: allowedColumns
#         resolvers: [forge.newDataInsertResolver()]
#
#       hinoki.get(container, 'insertUser')
#         .then (accessor) ->
#           test.equal result, accessor data
#           test.done()
#
#     'insertUserWithConnection': (test) ->
#       test.expect 4
#       result = {}
#       data = {}
#       allowedColumns = {}
#       connection = {}
#       table = {}
#       table.allow = (arg) ->
#         test.equal arg, allowedColumns
#         table
#       table.insert = (arg) ->
#         test.equal arg, data
#         result
#       table.setConnection = (arg) ->
#         test.equal arg, connection
#         table
#
#       container =
#         values:
#           userTable: table
#           userInsertableColumns: allowedColumns
#         resolvers: [forge.newDataInsertResolver()]
#
#       hinoki.get(container, 'insertUserWithConnection')
#         .then (accessor) ->
#           test.equal result, accessor data, connection
#           test.done()

###################################################################################
# update

  'parseUpdate': (test) ->
    test.ok not fragmentsPostgres.parseUpdate('update')
    test.ok not fragmentsPostgres.parseUpdate('updateWithConnection')
    test.ok not fragmentsPostgres.parseUpdate('updateOrderReport')?
    test.deepEqual fragmentsPostgres.parseUpdate('updateOrderReportWhereRegistrationNumber'),
      name: 'orderReport'
      where: ['registration_number']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseUpdate('updateOrderReportWhereRegistrationNumberWithConnection'),
      name: 'orderReport'
      where: ['registration_number']
      withConnection: true

    test.done()

#   'newDataUpdateResolver':
#
#     'updateUserWhereIdWhereCreatedAt': (test) ->
#       test.expect 4
#       calls =
#         where: []
#       result = {}
#       data = {}
#       allowedColumns = {}
#       table = {}
#       table.where = (arg) ->
#         calls.where.push arg
#         table
#       table.allow = (arg) ->
#         test.equal arg, allowedColumns
#         table
#       table.update = (arg) ->
#         test.equal arg, data
#         result
#
#       container =
#         values:
#           userTable: table
#           userUpdateableColumns: allowedColumns
#         resolvers: [forge.newDataUpdateResolver()]
#
#       hinoki.get(container, 'updateUserWhereIdWhereCreatedAt')
#         .then (accessor) ->
#           test.equal result, accessor data, 1, 2
#           test.deepEqual calls.where, [
#             {id: 1}
#             {created_at: 2}
#           ]
#           test.done()
#
#     'updateUserWhereIdWhereCreatedAtWithConnection': (test) ->
#       test.expect 5
#       calls =
#         where: []
#       result = {}
#       data = {}
#       allowedColumns = {}
#       connection = {}
#       table = {}
#       table.where = (arg) ->
#         calls.where.push arg
#         table
#       table.allow = (arg) ->
#         test.equal arg, allowedColumns
#         table
#       table.setConnection = (arg) ->
#         test.equal arg, connection
#         table
#       table.update = (arg) ->
#         test.equal arg, data
#         result
#
#       container =
#         values:
#           userTable: table
#           userUpdateableColumns: allowedColumns
#         resolvers: [forge.newDataUpdateResolver()]
#
#       hinoki.get(container, 'updateUserWhereIdWhereCreatedAtWithConnection')
#         .then (accessor) ->
#           test.equal result, accessor data, 1, 2, connection
#           test.deepEqual calls.where, [
#             {id: 1}
#             {created_at: 2}
#           ]
#           test.done()

###################################################################################
# delete

  'parseDelete': (test) ->
    test.ok not fragmentsPostgres.parseDelete('delete')
    test.ok not fragmentsPostgres.parseDelete('deleteWithConnection')
    test.ok not fragmentsPostgres.parseDelete('deleteOrderReport')?
    test.deepEqual fragmentsPostgres.parseDelete('deleteOrderReportWhereOrderId'),
      name: 'orderReport'
      where: ['order_id']
      withConnection: false
    test.deepEqual fragmentsPostgres.parseDelete('deleteOrderReportWhereOrderIdWithConnection'),
      name: 'orderReport'
      where: ['order_id']
      withConnection: true

    test.done()

#   'newDataDeleteResolver':
#
#     'deleteUserWhereIdWhereCreatedAt': (test) ->
#       test.expect 2
#       calls =
#         where: []
#       table = {}
#       result = {}
#       table.where = (arg) ->
#         calls.where.push arg
#         table
#       table.delete = ->
#         result
#
#       container =
#         values:
#           userTable: table
#         resolvers: [forge.newDataDeleteResolver()]
#
#       hinoki.get(container, 'deleteUserWhereIdWhereCreatedAt')
#         .then (accessor) ->
#           test.equal result, accessor 1, 2
#           test.deepEqual calls.where, [
#             {id: 1}
#             {created_at: 2}
#           ]
#           test.done()
#
#     'deleteUserWhereIdWhereCreatedAtWithConnection': (test) ->
#       test.expect 3
#       calls =
#         where: []
#       table = {}
#       result = {}
#       connection = {}
#       table.where = (arg) ->
#         calls.where.push arg
#         table
#       table.setConnection = (arg) ->
#         test.equal arg, connection
#         table
#       table.delete = ->
#         result
#
#       container =
#         values:
#           userTable: table
#         resolvers: [forge.newDataDeleteResolver()]
#
#       hinoki.get(container, 'deleteUserWhereIdWhereCreatedAtWithConnection')
#         .then (accessor) ->
#           test.equal result, accessor 1, 2, connection
#           test.deepEqual calls.where, [
#             {id: 1}
#             {created_at: 2}
#           ]
#           test.done()
