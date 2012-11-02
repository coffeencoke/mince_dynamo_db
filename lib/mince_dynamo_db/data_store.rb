module MinceDynamoDb # :nodoc:
  require 'singleton'
  require_relative 'connection'

  class DataStore
    include Singleton

    # Returns the collection, or table, for a given collection name
    # 
    # The schema must be loaded before any queries are made against a collection
    # There are a couple ways to do this, from digging in their documentation about
    # this topic.  One is to have the schema loaded in memory, which is not recommended
    # for production code, the other way is to call hash_key :) not sure why this works.
    #
    # @param [String] collection_name the name of the collection
    # @return [AWS::DynamoDB::Table] the AWS::DynamoDB::Table for the given collection_name
    def self.collection(collection_name)
      collections[collection_name.to_s].tap do |c|
        c.hash_key unless c.schema_loaded?
      end
    end

    # Returns the database object which comes from MinceDynamoDb::Connection
    def self.db
      instance.db
    end

    def self.collections
      db.tables
    end

    def self.items(collection_name)
      collection(collection_name).items
    end

    attr_accessor :db

    def db
      @db ||= Connection.connection
    end
  end
end
