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
domain = require 'domain'
random = require 'mongoose-random'
path = require 'path'

debug = require('debug')('stdin/models/page')

PageSchema = new Mongo.Schema
  link:        { type: String, index:{ unique:true }, required:true }
  pubDate:     { type: Date, index:true }
  feed:        { type: Mongo.Schema.Types.ObjectId, ref: 'feeds' }
  article:     { type: Mongo.Schema.Types.Mixed }
  keywords:    { type: String }
  isbn:        [{ type: String }]

# Plugins
PageSchema.plugin(random, { path: 'r' })

# Validations
PageSchema.path('link').validate (link)->
  return !(link is null or link is undefined or link is "" or not /http/.test link)
,"link url notfound error"

# Middleware
PageSchema.post 'save',(doc)->


# Model Methods

# upsertの代わり:findAndUpdateだとmiddlewareが発火しない為分けた
PageSchema.statics.upsertOneWithFeed = (article,feed,callback)->
  @findOne link:article.link,(err,doc)=>
    return callback err,null if err
    return callback null,doc if doc
    @create
      link: article.link
      pubDate: article.pubDate
      article:article
      feed:feed._id
    ,(err,doc)->
      return callback err,null if err
      return callback null,doc

exports.Page = Mongo.model 'pages', PageSchema
