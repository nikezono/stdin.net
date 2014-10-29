###

  feedSchema.coffee
  準拠:FeedParser
  https://github.com/danmactough/node-feedparser#list-of-meta-properties

  * url      [String] {Unique}  フィードのURL
  * pages    [ObjectId]         PageオブジェクトのArray
  * feed     [Object]           Feedオブジェクト(FeedParser)

###

Mongo = require 'mongoose'

FeedSchema = new Mongo.Schema
  url:   { type: String,  index: { unique: true } }
  pages: [{ type: Mongo.Schema.Types.ObjectId, ref: 'pages', default:[] }]
  feed:  { type: Mongo.Schema.Types.Mixed }

exports.Feed = Mongo.model 'feeds', FeedSchema
