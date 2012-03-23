# What is mince dynamo db?

Light weight ORM to persist data to an Amazon DynamoDB database.

Provides a very light weight interface for storing and retreiving information to DynamoDB.

The motivation behind this is so your application is not tightly tied to a specific database.  As your application grows you may need to upgrade to a different database or pull specific models to a different persistence strategy.

[@github](https://github.com/coffeencoke/mince_dynamo_db)
[@rubygems (not yet published)](#)

# How to use

view the [example mince rails app](https://github.com/coffeencoke/mince_rails_example) to see how to use this.

<pre>
# Add a book to the books collection
MinceDynamoDb::DataStore.add 'books', title: 'The World In Photographs', publisher: 'National Geographic'

# Retrieve all records from the books collection
MinceDynamoDb::DataStore.find_all 'books'

# Replace a specific book
MinceDynamoDb::DataStore.replace 'books', id: 1, title: 'A World In Photographs', publisher: 'National Geographic'
</pre>

View the docs for MinceDynamoDb::DataStore for all methods available.

Use with [mince data model](https://github.com/asynchrony/mince_data_model) to make it easy to change from one data storage to another, like [Hashy Db](https://github.com/asynchrony/hashy_db), a Hash data persistence implementation, or [Mince](https://github.com/asynchrony/mince), a MongoDB implementation.

# Why would you want this?

- To defer choosing your database until you know most about your application.
- Provides assitance in designing a database agnostic architecture.
- When used along with [Hashy Db](https://github.com/asynchrony/hashy_db) it offers very little technical dependencies.  Use Hashy Db in development mode so that you can clone the repo and develop, and run tests, cucumbers without databases, migrations, etc.  Then in production mode, switch to Mince Dynamo DB.

If you are able to switch between Hashy Db and Mince Dynamo Db, your application will be more open to new and improved database in the future, or as your application evolves you aren't tied to a database.


# Todo

- Write integration specs
- Do not use singleton for data store
- Refactor data store
- Remove dependency on Active Support

# Contribute

- fork into a topic branch, write specs, make a pull request.

# Owners

Matt Simpson - [@railsgrammer](https://twitter.com/railsgrammer)

# Contributors

- Your name here!

![Mince Some App](https://github.com/coffeencoke/gist-files/raw/master/images/mince%20garlic.png)
