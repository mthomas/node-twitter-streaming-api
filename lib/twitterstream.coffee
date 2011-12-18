https = require('https')
Buffer = require('buffer').Buffer
EventEmitter = require('events').EventEmitter
_ = require('underscore')
LineParser = require('line-parser')

class TwitterStream extends EventEmitter
  constructor: (@options) ->
    lineParser = new LineParser()

    lineParser.on 'line', (line) =>
      @emit 'tweet', line

    headers = {}

    headers['Authorization'] = @basicAuth @options.username, @options.password

    options =
      host: 'stream.twitter.com',
      path: '/1/statuses/filter.json?track=' + @options.track
      headers: headers

    request = https.get options, (response) =>
      response.setEncoding 'utf8'

      response.on 'data', (chunk) =>
        lineParser.chunk chunk

  basicAuth: (user, pass) ->
    return "Basic " + new Buffer(user + ":" + pass).toString('base64')

exports.TwitterStream = TwitterStream
