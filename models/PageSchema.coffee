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

debug = require('debug')('stdin/models/page')

PageSchema = new Mongo.Schema
  link:        { type: String, index:{ unique:true }, required:true }
  feed:        { type: Mongo.Schema.Types.ObjectId, ref: 'feeds' }
  article:     { type: Mongo.Schema.Types.Mixed }
  body:        { type: String, default:"" }
  keywords:    { type: [String], default:[] }
  content:     { type: String, default:"" }
PageSchema.plugin random,{path:"r"}

# Validations
PageSchema.path('link').validate (link)->
  return !(link is null or link is undefined or link is "" or not /http/.test link)
,"link url notfound error"

# Middleware
PageSchema.post 'save',(doc)->
  debug "Saved: #{doc.link}"
  analyzeQueue.push doc

# Model Methods

# upsertの代わり:findAndUpdateだとmiddlewareが発火しない為分けた
PageSchema.statics.upsertOneWithFeed = (article,feed,callback)->
  @findOne link:article.link,(err,doc)=>
    return callback err,null if err
    return callback null,doc if doc
    @create
      link: article.link
      article:article
      feed:feed._id
    ,(err,doc)->
      return callback err,null if err
      return callback null,doc

exports.Page = Mongo.model 'pages', PageSchema

# Utility

# 本文を取得し、特徴語を抽出するキュー
analyzeQueue = async.queue (page,callback)->

  debug "AnalyzeQueue: #{page.link} Start."

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
      ,(err)->
        return app.emit 'error',err if err
        debug "Analyzed. #{page.link}"
  ,2

