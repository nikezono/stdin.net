###

 キーワード検索

Input: "うちの庭には二羽の鶏がいるけど、きみんちの庭はどうなの"
Output:
  {"庭":2},
  {"二羽":1},
  {"いる":1},
  ...

このフォーマットでキーワード出力が出来れば、以下の実装はいくら変えても良し

@note HerokuではCネイティブのライブラリをインストールさせられないので、MeCabが使いづらい.(方法はいくつかあるが)

@version 14/11/12 TinySegmenter.js(http://chasen.org/~taku/software/TinySegmenter/)を用いる

###

TinySegmenter = require './tinysegmenter.js'

module.exports = (input)->
  ts = new TinySegmenter()
  hash = {}

  filtered = ""
  ## HTML Filter
  for seg in input.match new RegExp(/>.+?<\//g)
    filtered = filtered + seg.replace(/^>/,"").replace(/<\/$/,"")

  array = ts.segment filtered
  for word in array

    if not hash[word]
      hash[word] = 1
    else
      hash[word]++

  ## 二回以上言われていない言葉は切る
  for key,value of hash
    delete hash[key] if value < 2
    delete hash[key] if key.length < 3

  return hash
