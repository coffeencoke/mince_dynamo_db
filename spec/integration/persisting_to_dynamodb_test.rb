require_relative '../../lib/mince_dynamo_db'
require 'aws'

describe 'Testing mince_dynamo_db/data_store while actually hitting dynamo db:' do
  AWS.config.access_key_id = 'enter_access_key_id_here'
  AWS.config.secret_access_key = 'enter_secret_access_key_here'
  
  # Ensure clear db before tests
  before(:all) do
    MinceDynamoeDb::DataStore.instance.clear
  end

  # Ensure clear db after tests
  after(:all) do
    MinceDynamoeDb::DataStore.instance.clear
  end
end

