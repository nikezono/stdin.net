###

PostProcessing.coffee

データの後処理をやる
@note ディレクトリ違うか？

###

debug   = require('debug')('stdin/crawler/postProcessing')
domain  = require 'domain'
async   = require 'async'
request = require 'request'
path    = require 'path'
keyword = require path.resolve('crawler','keyword')

# 本文を取得し、特徴語を抽出するキュー
exports.AnalyzeQueue = async.queue (link,callback)->

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
