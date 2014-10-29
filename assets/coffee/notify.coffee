### Alert ###
window.notify =

  success:(text)->
    html5notification text
    $.bootstrapGrowl text,
      ele:"body"
      type:'success'
      allow_dismiss: true
      align: 'right'

  info:(text)->
    html5notification text
    $.bootstrapGrowl text,
      ele:"body"
      type:'info'
      allow_dismiss: true
      align: 'right'

  danger:(text)->
    html5notification text
    $.bootstrapGrowl text,
      ele:"body"
      type:'danger'
      allow_dismiss: true
      align: 'right'

html5notification = (text)->

  show = (text)->
    notification = new Notification "stdin.net",
      body:text
      tag:"test"
    setTimeout ->
      notification.close()
    ,1000*5 # 5秒

  if window.Notification.permission is "granted"
    show(text)


window.requestPermission =->
  if Notification.permission isnt "granted"
    Notification.requestPermission()
  else
    notify.info "Notification is already enabled"
