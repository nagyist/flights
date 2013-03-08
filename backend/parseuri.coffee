# parseUri 1.2.2
# (c) Steven Levithan <stevenlevithan.com>
# MIT License

exports.parse = (str) ->
  i = 14
  #console.log "trying to parse #{str}"
  #o = @options
  #m = o.parser[o.strictMode ? "strict" : "loose"].exec(str)
  #uri = {}
  #i = 14

	while i--
    uri[o.key[i]] = m[i] || ""

	uri[o.q.name] = {};
	uri[o.key[12]].replace(o.q.parser, ($0, $1, $2) ->
		if ($1) then uri[o.q.name][$1] = $2)

	uri

exports.parse.options =
	strictMode: false
	key: ["source","protocol","authority","userInfo","user","password","host",
          "port","relative","path","directory","file","query","anchor"]
	q:
		name:   "queryKey"
		parser: /(?:^|&)([^&=]*)=?([^&]*)/g
	parser:
		strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
		loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/

exports.queryDict = (url) ->
  query = parseUri(url).query;
  vars = query.split('&');
  result = {};
  for variable in vars
    pair = variable.split('=')
    result[decodeURIComponent(pair[0])] = decodeURIComponent(pair[1])

  result
