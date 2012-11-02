# MinceDynamoDb

MinceDynamoDb is a ruby ORM to provide a quick way to develop with an Amazon DynamoDb database in Ruby applications.

It is a database interface that abides to the [Mince](https://github.com/coffeencoke/mince/) interface API requirements and is officially supported by [Mince](https://github.com/coffeencoke/mince/).

# How to use it

View the [Mince Wiki](https://github.com/coffeencoke/mince/wiki) on details on how to use this gem.

Basically -

```
gem install mince_dynamo_db
```

```ruby
require 'mince_dynamo_db'

interface = MinceDynamoDb::Interface
interface.add 'tron_light_cycles', luminating_color: 'red', grid_locked: true, rezzed: false
interface.add 'tron_light_cycles', luminating_color: 'blue', grid_locked: true, rezzed: true
interface.find_all('tron_light_cycles') 
	# => [{:luminating_color=>"red", :grid_locked=>true, :rezzed=>false}, {:luminating_color=>"blue", :grid_locked=>true, :rezzed=>true}] 
interface.get_for_key_with_value('tron_light_cycles', :luminating_color, 'blue')
	# => {:luminating_color=>"blue", :grid_locked=>true, :rezzed=>true} 
```

Configuring MinceDynamoDb to use your Amazon DynamoDb instance:

```ruby
# Change the values to your credential info
MinceDynamoDb::Config.secret_access_key = 'asdf1234iuoyasdfkljhqweriouy12341234asdf'
MinceDynamoDb::Config.access_key_id = '123asd123asd123asd12'
```

# Links

* [API Docs](http://rdoc.info/github/coffeencoke/mince_dynamo_db/master/frames)
* [Travis CI](https://travis-ci.org/#!/coffeencoke/mince_dynamo_db)
* [Rubygems](https://rubygems.org/gems/mince_dynamo_db)
* [Github](https://github.com/coffeencoke/mince_dynamo_db)
* [Wiki](https://github.com/coffeencoke/mince_dynamo_db/wiki)
* [Issues](https://github.com/coffeencoke/mince_dynamo_db/issues)
* [Mince](https://github.com/coffeencoke/mince)

# Contribute

This gem is officially supported by [Mince](https://github.com/coffeencoke/mince/), please go there to learn how to contribute.
