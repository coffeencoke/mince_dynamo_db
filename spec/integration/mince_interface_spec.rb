require_relative '../../lib/dynamo_db'
require 'mince/shared_examples/interface_example'

describe 'Mince Interface with DynamoDb' do
  pending do
  before do
    AWS.config(
      :use_ssl => false,
      :dynamo_db_endpoint => 'localhost',
      :access_key_id => "xxx",
      :secret_access_key => "xxx"
    )
    Mince::Config.interface = Mince::DynamoDb::Interface
  end

  it_behaves_like 'a mince interface'
end
end
