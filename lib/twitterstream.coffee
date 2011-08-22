http = require('http')
Buffer = require('buffer').Buffer
EventEmitter = require('events').EventEmitter
_ = require('underscore')

# Turns group of chunks into a group of lines
# emits event 'line'
class LineParser extends EventEmitter
  constructor: () ->
    @buffer = ''

  handleChunk: (chunk) ->
    @buffer += chunk
    if @buffer.indexOf('\n') != -1
      lines = @buffer.split('\n')
      if lines.length == 1
        @emit 'line', lines[0]
        @buffer = ''
      else
        _(lines).chain().first(lines.length-1).each (line) =>
          @emit 'line', line
        @buffer = _.last(lines);

class TwitterStream extends EventEmitter
  constructor: (@options) ->
    lineParser = new LineParser()

    lineParser.on 'line', (line) =>
      @emit 'tweet', line

    headers = {}

    headers['Authorization'] = @basicAuth @options.username, @options.password

    options =
      host: 'stream.twitter.com',
      port: 80,
      path: '/1/statuses/filter.json?track=' + @options.track
      headers: headers

    request = http.get options, (response) =>
      response.setEncoding 'utf8'

      response.on 'data', (chunk) =>
        lineParser.handleChunk chunk

  basicAuth: (user, pass) ->
    return "Basic " + new Buffer(user + ":" + pass).toString('base64')

exports.TwitterStream = TwitterStream