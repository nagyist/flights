fs = require 'fs'
common = require './common'
_ = require 'underscore'

designId = '_design/validation'

schema_version = 3

validateDocUpdate = (newDoc, oldDoc, userCtx, secObj) ->
  if not newDoc._deleted?
    _ = require 'lib/underscore'
    validate = require('lib/json-schema').validate
    schemas = require('lib/schema').schemas

    results = _.map schemas, (schema) -> validate newDoc, schema

    if not (_.any results, (result) -> result.valid)
      throw { forbidden: JSON.stringify(_.pluck results, 'errors') }

common.httpGet common.validationDocUrl, (doc) ->
  validationDocument =
    _id: designId
    lib:
      'json-schema': common.stringifyModule 'json-schema', 'commonjs-utils'
      schema: fs.readFileSync "schema#{schema_version}.js", 'UTF-8'
      underscore: common.stringifyModule 'underscore', 'underscore'
    validate_doc_update: validateDocUpdate + ''

  if doc._rev?
    validationDocument._rev = doc._rev
  if doc.lib.schema isnt validationDocument.lib.schema or
      doc.validate_doc_update isnt validationDocument.validate_doc_update
    common.httpPut common.validationDocUrl, validationDocument, (response) ->
      console.log response

common.allDocs (docs) ->
  for doc in docs when doc._id isnt designId and doc.schema_version < schema_version
    doc.schema_version = schema_version
    switch doc.type
      when 'timetable_item'
        prices = {}
        prices[doc.timestamp + ''] = doc.price
        doc.prices = prices
        delete doc.price
      when 'flight'
        doc.timetable_timestamps = {}
    doc.migrated = true

  bulk_update =
    docs: _(docs).chain().reject((doc) -> doc._id is designId or not doc.migrated)
      .map((doc) -> delete doc.migrated; doc).value()

  if bulk_update.docs.length > 0
    common.httpPost "#{ common.rootUrl }_bulk_docs", bulk_update, (response_object) ->
      console.log response_object
