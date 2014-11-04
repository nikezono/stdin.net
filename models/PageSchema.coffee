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
  link:        { type: String, index:{ unique:true }, required:true }
  feed:        { type: Mongo.Schema.Types.ObjectId, ref: 'feeds' }
  article:     { type: Mongo.Schema.Types.Mixed }
  body:        { type: String, default:"" }
  keywords:    { type: [String], default:[] }
  content:     { type: String, default:"" }

# Validations
PageSchema.path('link').validate (value)->
  return link is null or link is undefined or link is "" or "http".test link
,"link url notfound error"

# Middleware
PageSchema.post 'save',(doc)->
  analyzeQueue.push doc

# Model Methods
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

# Utility

# 本文を取得し、特徴語を抽出するキュー
analyzeQueue = async.queue (page,callback)->

  # ここでのエラーはイベントだけ吐いて飲み込む
  d = domain.create()
  d.on 'error',(err)->
    app.emit 'error',err
    return callback()
  d.run ->

    request page.link,(err,res,body)->
      if err
        app.emit 'error', err
        return callback()
      if res.statusCode isnt 200
        debug "error analyzeQueue:#{page.link} #{res.statusCode}"
        return callback()

      # @todo キーワード抽出
      page.update
        body:body
      ,save (err)->
        app.emit 'error',err
        debug "Analyzed. #{page.link}"
  ,2

