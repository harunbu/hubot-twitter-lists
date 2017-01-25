Twitter = require('twitter');

getTweetUrl = (screen_name, id_str) ->
  "https://twitter.com/#{screen_name}/status/#{id_str}"

module.exports = (robot) ->
  client = new Twitter
    consumer_key: process.env.HUBOT_TWITTER_LISTS_CONSUMER_KEY
    consumer_secret: process.env.HUBOT_TWITTER_LISTS_CONSUMER_SECRET
    access_token_key: process.env.HUBOT_TWITTER_LISTS_ACCESS_TOKEN_KEY
    access_token_secret: process.env.HUBOT_TWITTER_LISTS_ACCESS_TOKEN_SECRET

  params =
    list_id: process.env.HUBOT_TWITTER_LISTS_LIST_ID
    include_rts: process.env.HUBOT_TWITTER_LISTS_INCLUDE_RTS || true

  checkTask = setInterval ->
    sinceId = robot.brain.data.sinceId || 0;
    if sinceId > 0
      params.since_id = sinceId
    client.get 'lists/statuses', params, (error, tweets, response) ->
      if error
        robot.send room:process.env.HUBOT_TWITTER_LISTS_ROOM, util.inspect error
        clearInterval checkTask
      else if tweets.length > 0
        robot.brain.data.sinceId = tweets[0].id_str
        robot.send room:process.env.HUBOT_TWITTER_LISTS_ROOM, getTweetUrl tweet.user.screen_name, tweet.id_str for tweet in tweets
  , 1000 * 60
