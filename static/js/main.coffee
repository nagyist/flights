dojo.ready ->
  dojo.query('#inputSubmit').onclick submit

submit = ->
  source = dojo.attr 'inputSource', 'value'
  destination = dojo.attr 'inputDestination', 'value'
  imageSrc = "/timetable?src=#{ source }&dst=#{ destination }"
  dojo.query('#resultImage').attr('src', imageSrc)
