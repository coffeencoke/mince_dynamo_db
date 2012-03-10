require 'aws'
require 'singleton'

module MinceDynamoDb
  class Connection
    include Singleton

    attr_reader :connection

    def initialize
      @connection = AWS::DynamoDB.new access_key_id: access_key_id, secret_access_key: secret_access_key
    end

    private

    def access_key_id
      AWS.config.access_key_id
    end

    def secret_access_key
      AWS.config.secret_access_key
    end
  end
end