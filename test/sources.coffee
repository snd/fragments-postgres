test = require 'tape'
hinoki = require 'hinoki'

fragmentsPostgres = require '../lib/fragments-postgres'

###################################################################################
# table

test 'userTable', (t) ->
  calls =
    table: []
  mesa = {}
  table = {}
  mesa.table = (arg) ->
    calls.table.push arg
    table

  lifetime =
    mesa: mesa

  hinoki(fragmentsPostgres, lifetime, 'fragments_userTable')
    .then (result) ->
      t.equal result, table
      t.deepEqual calls.table, ['user']
      t.end()

test 'projectMessageTable', (t) ->
  calls =
    table: []
  mesa = {}
  table = {}
  mesa.table = (arg) ->
    calls.table.push arg
    table

  lifetime =
    mesa: mesa

  hinoki(fragmentsPostgres, lifetime, 'fragments_projectMessageTable')
    .then (result) ->
      t.equal result, table
      t.deepEqual calls.table, ['project_message']
      t.end()

###################################################################################
# select

test 'parseSelect', (t) ->
  t.ok not fragmentsPostgres.parseSelect('fragments_first')
  t.ok not fragmentsPostgres.parseSelect('fragments_firstWithConnection')
  t.deepEqual fragmentsPostgres.parseSelect('fragments_firstUser'),
    type: 'first'
    table: 'user'
    order: []
    where: []
    withConnection: false
  t.deepEqual fragmentsPostgres.parseSelect('fragments_firstUserWithConnection'),
    type: 'first'
    table: 'user'
    order: []
    where: []
    withConnection: true
  t.deepEqual fragmentsPostgres.parseSelect('fragments_selectUserCreatedAt'),
    type: 'select'
    table: 'user_created_at'
    order: []
    where: []
    withConnection: false
  t.deepEqual fragmentsPostgres.parseSelect('fragments_selectUserCreatedAtWithConnection'),
    type: 'select'
    table: 'user_created_at'
    order: []
    where: []
    withConnection: true
  t.deepEqual fragmentsPostgres.parseSelect('fragments_firstUserWhereCreatedAt'),
    type: 'first'
    table: 'user'
    order: []
    where: ['created_at']
    withConnection: false
  t.deepEqual fragmentsPostgres.parseSelect('fragments_firstUserWhereCreatedAtWithConnection'),
    type: 'first'
    table: 'user'
    order: []
    where: ['created_at']
    withConnection: true
  t.deepEqual fragmentsPostgres.parseSelect('fragments_selectOrderReportWhereOrderIdWhereCreatedAt'),
    type: 'select'
    table: 'order_report'
    order: []
    where: ['order_id', 'created_at']
    withConnection: false
  t.deepEqual fragmentsPostgres.parseSelect('fragments_firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDesc'),
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
  t.deepEqual fragmentsPostgres.parseSelect('fragments_firstOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtDescWithConnection'),
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
  t.deepEqual fragmentsPostgres.parseSelect('fragments_selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAsc'),
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
  t.deepEqual fragmentsPostgres.parseSelect('fragments_selectOrderReportWhereOrderIdWhereCreatedAtOrderByCreatedAtOrderByIdDescOrderByReportNumberAscWithConnection'),
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

  t.end()

test 'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrder', (t) ->
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
      t.equal result, accessor 1, 2
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.deepEqual calls.order, ['updated_at DESC, order ASC']
      t.end()

test 'firstUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrderWithConnection', (t) ->
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
    t.equal arg, connection
    table
  table.first = ->
    result

  lifetime =
    userTable: table

  hinoki(fragmentsPostgres, lifetime, 'fragments_firstUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrderWithConnection')
    .then (accessor) ->
      t.equal result, accessor 1, 2, connection
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.deepEqual calls.order, ['updated_at DESC, order ASC']
      t.end()

test 'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrder', (t) ->
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
      t.equal result, accessor 1, 2
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.deepEqual calls.order, ['updated_at DESC, order ASC']
      t.end()

test 'selectUserWhereIdWhereCreatedAtOrderByUpdatedAtOrderByOrderWithConnection', (t) ->
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
    t.equal arg, connection
    table
  table.find = ->
    result

  lifetime =
    userTable: table

  hinoki(fragmentsPostgres, lifetime, 'fragments_selectUserWhereIdWhereCreatedAtOrderByUpdatedAtDescOrderByOrderWithConnection')
    .then (accessor) ->
      t.equal result, accessor 1, 2, connection
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.deepEqual calls.order, ['updated_at DESC, order ASC']
      t.end()

###################################################################################
# insert

test 'parseInsert', (t) ->
  t.ok not fragmentsPostgres.parseInsert('fragments_insert')
  t.ok not fragmentsPostgres.parseInsert('fragments_insertWithConnection')
  t.deepEqual fragmentsPostgres.parseInsert('fragments_insertOrderReport'),
    table: 'order_report'
    withConnection: false
  t.deepEqual fragmentsPostgres.parseInsert('fragments_insertUserWhere'),
    table: 'user_where'
    withConnection: false
  t.deepEqual fragmentsPostgres.parseInsert('fragments_insertUserWhereWithConnection'),
    table: 'user_where'
    withConnection: true

  t.end()

test 'insertUser', (t) ->
  t.plan 3
  result = {}
  data = {}
  allowedColumns = {}
  table = {}
  table.allow = (arg) ->
    t.equal arg, allowedColumns
    table
  table.insert = (arg) ->
    t.equal arg, data
    result

  lifetime =
    userTable: table
    userInsertableColumns: allowedColumns

  hinoki(fragmentsPostgres, lifetime, 'fragments_insertUser')
    .then (accessor) ->
      t.equal result, accessor data
      t.end()

test 'insertUserWithConnection', (t) ->
  t.plan 4
  result = {}
  data = {}
  allowedColumns = {}
  connection = {}
  table = {}
  table.allow = (arg) ->
    t.equal arg, allowedColumns
    table
  table.insert = (arg) ->
    t.equal arg, data
    result
  table.setConnection = (arg) ->
    t.equal arg, connection
    table

  lifetime =
    userTable: table
    userInsertableColumns: allowedColumns

  hinoki(fragmentsPostgres, lifetime, 'fragments_insertUserWithConnection')
    .then (accessor) ->
      t.equal result, accessor data, connection
      t.end()

###################################################################################
# update

test 'parseUpdate', (t) ->
  t.ok not fragmentsPostgres.parseUpdate('fragments_update')
  t.ok not fragmentsPostgres.parseUpdate('fragments_updateWithConnection')
  t.ok not fragmentsPostgres.parseUpdate('fragments_updateOrderReport')?
  t.deepEqual fragmentsPostgres.parseUpdate('fragments_updateOrderReportWhereRegistrationNumber'),
    table: 'order_report'
    where: ['registration_number']
    withConnection: false
  t.deepEqual fragmentsPostgres.parseUpdate('fragments_updateOrderReportWhereRegistrationNumberWithConnection'),
    table: 'order_report'
    where: ['registration_number']
    withConnection: true

  t.end()

test 'updateUserWhereIdWhereCreatedAt', (t) ->
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
    t.equal arg, allowedColumns
    table
  table.update = (arg) ->
    t.equal arg, data
    result

  lifetime =
    userTable: table
    userUpdateableColumns: allowedColumns

  hinoki(fragmentsPostgres, lifetime, 'fragments_updateUserWhereIdWhereCreatedAt')
    .then (accessor) ->
      t.equal result, accessor data, 1, 2
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.end()


test 'updateUserWhereIdWhereCreatedAtWithConnection', (t) ->
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
    t.equal arg, allowedColumns
    table
  table.setConnection = (arg) ->
    t.equal arg, connection
    table
  table.update = (arg) ->
    t.equal arg, data
    result

  lifetime =
    userTable: table
    userUpdateableColumns: allowedColumns

  hinoki(fragmentsPostgres, lifetime, 'fragments_updateUserWhereIdWhereCreatedAt')
    .then (accessor) ->
      t.equal result, accessor data, 1, 2, connection
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.end()

###################################################################################
# delete

test 'parseDelete', (t) ->
  t.ok not fragmentsPostgres.parseDelete('fragments_delete')
  t.ok not fragmentsPostgres.parseDelete('fragments_deleteWithConnection')
  t.ok not fragmentsPostgres.parseDelete('fragments_deleteOrderReport')?
  t.deepEqual fragmentsPostgres.parseDelete('fragments_deleteOrderReportWhereOrderId'),
    table: 'order_report'
    where: ['order_id']
    withConnection: false
  t.deepEqual fragmentsPostgres.parseDelete('fragments_deleteOrderReportWhereOrderIdWithConnection'),
    table: 'order_report'
    where: ['order_id']
    withConnection: true

  t.end()

test 'deleteUserWhereIdWhereCreatedAt', (t) ->
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
      t.equal result, accessor 1, 2
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.end()

test 'deleteUserWhereIdWhereCreatedAtWithConnection', (t) ->
  calls =
    where: []
  table = {}
  result = {}
  connection = {}
  table.where = (arg) ->
    calls.where.push arg
    table
  table.setConnection = (arg) ->
    t.equal arg, connection
    table
  table.delete = ->
    result

  lifetime =
    userTable: table

  hinoki(fragmentsPostgres, lifetime, 'fragments_deleteUserWhereIdWhereCreatedAtWithConnection')
    .then (accessor) ->
      t.equal result, accessor 1, 2, connection
      t.deepEqual calls.where, [
        {id: 1}
        {created_at: 2}
      ]
      t.end()
