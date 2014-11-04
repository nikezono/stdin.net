###
#
# はてなのホッテントリからひたすらにfind-rssしまくる
#
###

request = require 'request'
cheerio = require 'cheerio'
async   = require 'async'
debug   = require('debug')('stdin/crowler/hatenaHotentry')

module.exports = (app)->

  FeedEvent = app.get('events').FeedEvent app

  request "http://b.hatena.ne.jp/hotentry",(err,res,body)->
    if err or res.statusCode isnt 200
      return debug "can't connect hotentry url. err:#{err} res:#{res.statusCode}"
    $ = cheerio.load body
    $('.hb-entry-link-container a').each (e)->
      entryUrl = $(this).attr("href")
      debug "StartWith:#{entryUrl}"

      recursiveFind = async.queue (url,callback)->
        debug "Find-RSS Start:#{url}"
        # Find-RSSして全件追加
        FeedEvent.findFeedAlias url,(err,urls)->

          # 結果をデバッグ出力
          if err
            debug "Find-RSS Error:#{url}"
            app.emit 'error', err
          else
            if urls.added.length is 0 and urls.alreadyAdded.length is 0
              debug "Find-RSS Notfound:#{url}"
            else
              debug "Find-RSS founded:#{url} registered:#{urls.added}"
              debug "Find-RSS founded:#{url} already:#{urls.alreadyAdded}"

          # URLのパスを切って再探索
          array = url.split('/')
          if array.length > 3 # http://hostname までは許す
            pop = array.pop()
            poped = array.join('/')
            debug "Find-RSS pop:#{pop} retryWith:#{poped}"
            recursiveFind.push poped
          else
            debug "Find-RSS #{url} is reach End"
          return callback()
        ,3 # キュー数
      recursiveFind.push entryUrl

