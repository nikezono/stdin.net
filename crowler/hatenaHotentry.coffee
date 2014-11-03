###
#
# はてなのホッテントリからひたすらにfind-rssしまくる
#
###

request = require 'request'
cheerio = require 'cheerio'
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

      recursiveFind = (url)->
        debug "Find-RSS #{url}"
        FeedEvent.findFeedAlias url,(err,urls)->
          if err or (urls.added is null and urls.alreadyAdded is null)
            array = url.split('/')
            if array.length > 2
              array.pop()
              poped = array.join('/')
              debug "notfound:#{url} retryWith:#{poped}"
              recursiveFind poped
          else
            debug "founded:#{url}"

      recursiveFind entryUrl

