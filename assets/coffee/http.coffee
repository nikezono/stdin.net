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

  # 類似記事取得
  getSimilarArticles:(id,callback)->
    $.getJSON "/api/page/#{id}/similar"
    .success (data)->
      callback null,data
    .error (err)->
      callback err,null

