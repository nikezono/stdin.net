window.httpApiWrapper =

  # 購読できるフィード/ストリームの検索
  findFeed:(url,callback)->
    $.getJSON "/api/feed/find",
      url:url
    .success (data)->
      callback null,data
    .error (err)->
      callback err,null

 # 最新記事取得
  getLatestArticles:(callback)->
    $.getJSON "/api/page/latest"
    .success (data)->
      callback null,data
    .error (err)->
      callback err,null

  postSubscribeFeed:(data,callback)->
    $.ajax "/api/feed/subscribe",
      type:"POST"
      data:
        feed:JSON.stringify data.feed
      success:(data)->
        callback null,data
      error: (err)->
        callback err,null



