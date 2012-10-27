module Mince
  module DynamoDb
    require 'singleton'
    require_relative 'config'
    require 'aws/dynamo_db'

    class Connection
      include Singleton

      def self.connection
        instance.connection
      end

      attr_accessor :connection

      def connection
        @connection ||= AWS::DynamoDB.new(access_key_id: Config.access_key_id, secret_access_key: Config.secret_access_key)
      end
    end
  end
end
