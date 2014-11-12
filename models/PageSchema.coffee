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

keyword = require path.resolve 'crawler/keyword'
debug = require('debug')('stdin/models/page')

PageSchema = new Mongo.Schema
  link:        { type: String, index:{ unique:true }, required:true }
  pubDate:     { type: Date, index:true }
  feed:        { type: Mongo.Schema.Types.ObjectId, ref: 'feeds' }
  article:     { type: Mongo.Schema.Types.Mixed }
  keywords:    { type: String }

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

      # Analyzeのタスク飛ばしておく
      analyzeQueue.push doc.link,(result)->
        return debug result.error if result.error
        doc.update
          keywords:JSON.stringify result.keywords # Keyにイロイロ入るのでString
        ,(err)->
          return debug err if err
          return debug "Analyzed.#{doc.link}"

      return callback null,doc

exports.Page = Mongo.model 'pages', PageSchema

# Utility

# 本文を取得し、特徴語を抽出するキュー
exports.AnalyzeQueue = analyzeQueue = async.queue (link,callback)->

  debug "AnalyzeQueue: #{link} Start."

  # ここでのエラーはイベントだけ吐いて飲み込む
  d = domain.create()
  d.on 'error',(err)-> return callback error:err
  d.run ->

    request link,(err,res,body)->
      return callback error:err if err
      if res.statusCode isnt 200
        debug "error analyzeQueue:#{link} #{res.statusCode}"
        return callback error:new Error("Bad Status Code")
      keywords = keyword body
      return callback
        keywords:keywords
  ,process.env.ANALYZEQUEUE || 2
