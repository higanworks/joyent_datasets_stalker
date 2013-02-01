require 'redis'
require 'redis-namespace'
require './lib/datasets'

task :default => [:test]

desc "run cucumber"
task :test do
  system("cucumber --color")
end

namespace :sidekiq do
  desc "start sidekiq"
  task :run do
    system("bundle exec sidekiq -c 5 -r ./tasks/post_to_twitter_worker.rb")
  end

  desc "start sidekiq use localenv"
  task :local do
    require './env/local.rb'
    system("bundle exec sidekiq -v -c 5 -r ./tasks/post_to_twitter_worker.rb")
  end

  desc "pry use localenv"
  task :pry do
    require './env/local.rb'
    system("pry -r ./tasks/post_to_twitter_worker.rb")
  end
end


namespace :perform do

  def redis_setup
    r = Redis.new(:url => ENV['REDISTOGO_URL'])
    redis = Redis::Namespace.new(:jstalker, :redis => r) 
    redis
  end

  desc "perform with local env"
  task :local do
    require './env/local.rb'
    require './tasks/post_to_twitter_worker'

    worker = JoyentStalker::Datasets.new(redis_setup)
    worker.update_staging_sets

    # prepare to test
    redis_setup.spop :staging_sets
    redis_setup.spop :staging_sets
    redis_setup.spop :current_sets
    redis_setup.spop :current_sets

    # print old dataset
    worker.find_gone_datasets.each do |dataset|
      DummyWorker.perform_async("dataset disappeared. #{dataset}" ,["#test_tweet"])
      PostWorker.perform_async("dataset disappeared. #{dataset}" ,["#test_tweet"])
    end

    # print new dataset
    worker.find_new_datasets.each do |dataset|
      DummyWorker.perform_async("New dataset appeared. #{dataset}" ,["#test_tweet"])
      PostWorker.perform_async("New dataset appeared. #{dataset}" ,["#test_tweet"])
    end

    worker.save_current_sets
    redis_setup.flushdb
  end

  desc "perform with heroku env"
  task :heroku do
    require './tasks/post_to_twitter_worker'

    worker = JoyentStalker::Datasets.new(redis_setup)
    worker.update_staging_sets

    # print old dataset
    worker.find_gone_datasets.each do |dataset|
      PostWorker.perform_async("dataset disappeared. #{dataset}" ,["#joyent"])
    end

    # print new dataset
    worker.find_new_datasets.each do |dataset|
      PostWorker.perform_async("New dataset appeared. #{dataset}" ,["#joyent"])
    end

    worker.save_current_sets
  end
end


