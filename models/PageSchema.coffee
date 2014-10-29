###

  pageSchema.coffee
  準拠:feedParser
  https://github.com/danmactough/node-feedparser#list-of-article-properties

  * link         [String]     Identifier
  * feed         [ObjectId]   親FeedのId
  * article      [Object]     記事データ
###

Mongo = require 'mongoose'
async = require 'async'
_     = require 'underscore'
request = require 'request'

debug = require('debug')('stdin/models/page')

PageSchema = new Mongo.Schema
  link:        { type: String, index:{ unique:true } }
  feed:        { type: Mongo.Schema.Types.ObjectId, ref: 'feeds' }
  article:     { type: Mongo.Schema.Types.Mixed }

PageSchema.statics.upsertOneWithFeed = (article,feed,callback)->
  @findOneAndUpdate
    link: article.link
  ,
    article:article
    feed:feed._id
  ,
    upsert:true
  ,(err,page)->
    return callback err,null if err
    return callback null,page


exports.Page = Mongo.model 'pages', PageSchema
