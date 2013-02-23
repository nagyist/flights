fs = require 'fs'
common = require './common'
_ = require 'underscore'

designId = '_design/validation'

validateDocUpdate = (newDoc, oldDoc, userCtx, secObj) ->
  if not newDoc._deleted?
    _ = require 'lib/underscore'
    validate = require('lib/json-schema').validate
    schemas = require('lib/schema2').schemas

    results = _.map schemas, (schema) -> validate newDoc, schema

    if not (_.any results, (result) -> result.valid)
      throw { forbidden: JSON.stringify(_.pluck results, 'errors') }

common.httpGet common.validationDocUrl, (doc) ->
  validationDocument =
    _id: designId
    lib:
      'json-schema': common.stringifyModule 'json-schema', 'commonjs-utils'
      schema2: fs.readFileSync 'schema2.js', 'UTF-8'
      underscore: common.stringifyModule 'underscore', 'underscore'
    validate_doc_update: validateDocUpdate + ''

  if doc._rev?
    validationDocument._rev = doc._rev
  common.httpPut common.validationDocUrl, validationDocument, (response) ->
    console.log response

common.allDocs (docs) ->
  for doc in docs when doc._id isnt designId
    doc.schema_version = 2
    if doc.type is 'timetable_item'
      delete doc.source
      delete doc.destination

  docs =
  bulk_update =
    docs: _.reject(docs, (doc) -> doc._id is designId)

  common.httpPost "#{ common.rootUrl }_bulk_docs", bulk_update, (response_object) ->
    console.log response_object
