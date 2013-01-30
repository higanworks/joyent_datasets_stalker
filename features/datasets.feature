# Language: en

Feature: datasets import
  To create sets of dataset
  As a joyent user
  I want to be store to redis all datasets

  Background: Redis is available
    Given I have connect to redis with namespace test

  Scenario: Update staging dataset sets
    Given Current sets is empty
    When Retrieve joyent datasets from remote
    Then Update staging sets on Redis
    But Raise exception if remote data is empty

  @wip
  Scenario: Update current dataset sets
    Given staging sets is exist
    Then update current sets from staging
    But Raise exception if staging data is empty

  Scenario: Pick up new datasets
    Given I have current and staging sets on Redis
    And Some new datasets are available
    Then I can pick up new datasets

  Scenario: Find out gone datasets
    Given I have current and staging sets on Redis
    And Some datasets are gone
    Then I can find out gone datasets

