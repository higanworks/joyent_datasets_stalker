require 'twitter'
require 'sidekiq'

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'jstalker'}
  config.poll_interval = 10
end

Sidekiq.configure_client do |config|
    config.redis = { :namespace => 'jstalker'}
end

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

class PostWorker
  include Sidekiq::Worker
  
  sidekiq_options :retry => 5

  def perform(msg, hashtags = [])
    tags = hashtags.join(" ")
    ti = [msg, tags].join(" ")
    Twitter.update(ti)
  end
end


class DummyWorker
  include Sidekiq::Worker
  
  sidekiq_options :retry => 5

  def perform(msg, hashtags = [])
    tags = hashtags.join(" ")
    ti = [msg, tags].join(" ")
    puts ti
  end
end
