#
#  JoyentStalker::Datasets libraly
#
#
#  Copyright (C) 2013 HiganWorks LLC
#  Licensed under MIT https://github.com/higanworks/LICENSES
# 

require 'json'
require 'open-uri'
require 'openssl'
require 'redis'
require 'redis-namespace'


class JoyentStalker
  class Datasets
    # attr_accessor :staging_datasets, :staging_sets, :current_sets
    attr_accessor :staging_datasets

    def initialize(redis)
      @redis = redis
      @staging_datasets = self.retrieve_remote_datasets
    end

    def staging_sets
      self.get_smembers(:staging_sets)
    end

    def current_sets
      self.get_smembers(:current_sets)
    end


    def get_smembers(key)
      @redis.smembers key
    end

    def retrieve_remote_datasets
      datasets_uri = "https://datasets.joyent.com/datasets"
      options = {:ssl_verify_mode=>OpenSSL::SSL::VERIFY_NONE}
      remote_data = open(datasets_uri, "r", options)
      JSON.parse(remote_data.read)
    end

    def update_staging_sets
      raise "Caution: remote_data is empty." if self.staging_datasets.empty?
      @redis.multi do
        @redis.del :staging_sets
        self.staging_datasets.each do |dataset|
          @redis.sadd :staging_sets, [dataset['name'], dataset['version'], dataset['uuid']].join(":")
        end
      end

      ## initialize
      save_current_sets if current_sets == []
    end

    def save_current_sets
      raise "Caution: staging_set is empty." if self.staging_sets.empty?
      @redis.multi do
        @redis.del :current_sets
        @redis.sunionstore :current_sets, :staging_sets
      end
    end

    def find_new_datasets
      @redis.sdiff :staging_sets, :current_sets
    end

    def find_gone_datasets
      @redis.sdiff :current_sets, :staging_sets
    end

  end
end

