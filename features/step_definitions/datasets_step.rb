
Given /^I have connect to redis with namespace ([:\w]+)$/ do |namespace|
  r = Redis.new(:db => 10)
  @redis = Redis::Namespace.new(namespace.to_sym, :redis => r)
end

Given /^Current sets is empty$/ do
  @redis.flushdb
end

When /^Retrieve joyent datasets from remote$/ do
  @datasets = JoyentStalker::Datasets.new(@redis)
end

Then /^Update staging sets on Redis$/ do
  @datasets.update_staging_sets
  @redis.scard(:staging_sets).should_not nil
  @redis.scard(:staging_sets).should == @datasets.staging_datasets.length
end

Then /^Raise exception if remote data is empty$/ do
  @datasets.staging_datasets = {}
  lambda{@datasets.update_staging_sets}.should raise_error(RuntimeError, "Caution: remote_data is empty.")
end

Given /^staging sets is exist$/ do
  @datasets = JoyentStalker::Datasets.new(@redis)
  @datasets.update_staging_sets
end

Then /^update current sets from staging$/ do
  @datasets.save_current_sets
  a = @redis.smembers(:current_sets)
  b = @redis.smembers(:staging_sets)
  a.sort.should == b.sort
end


Given /^I have current and staging sets on Redis$/ do
  @datasets = JoyentStalker::Datasets.new(@redis)
  @datasets.update_staging_sets
  @datasets.save_current_sets
end

Then /^Raise exception if staging data is empty$/ do
  @redis.del :staging_sets
  lambda{@datasets.save_current_sets}.should raise_error(RuntimeError, "Caution: staging_set is empty.")
end


Given /^Some new datasets are available$/ do
  5.times do
    @redis.spop :current_sets
  end
end

Then /^I can pick up new datasets$/ do
  @datasets.find_new_datasets.length.should == 5
end

Given /^Some datasets are gone$/ do
  5.times do
    @redis.spop :staging_sets
  end
end

Then /^I can find out gone datasets$/ do
  @datasets.find_gone_datasets.length.should == 5
end


