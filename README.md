<img height=90 src=https://img.stackshare.io/misc/graphql-cache.png>

# GraphQL Cache
[![Gem Version](https://badge.fury.io/rb/graphql-cache.svg)](https://badge.fury.io/rb/graphql-cache) [![Build Status](https://travis-ci.org/stackshareio/graphql-cache.svg?branch=master)](https://travis-ci.org/stackshareio/graphql-cache) [![Test Coverage](https://api.codeclimate.com/v1/badges/524c0f23ed1dbf0f9338/test_coverage)](https://codeclimate.com/github/stackshareio/graphql-cache/test_coverage) [![Maintainability](https://api.codeclimate.com/v1/badges/524c0f23ed1dbf0f9338/maintainability)](https://codeclimate.com/github/stackshareio/graphql-cache/maintainability)

A custom caching plugin for [graphql-ruby](https://github.com/rmosolgo/graphql-ruby)

## Goals

- Provide resolver-level caching for [GraphQL](https://graphql.org) APIs written in ruby
- Configurable to work with or without Rails
- [API Documentation](https://www.rubydoc.info/gems/graphql-cache)

## Why?

At [StackShare](https://stackshare.io) we've been rolling out [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) for several of our new features and found ourselves in need of a caching solution.  We could have simply used `Rails.cache` in our resolvers, but this creates very verbose types or resolver classes.  It also means that each and every resolver must define it's own expiration and key.  GraphQL Cache solves that problem by integrating caching functionality into the [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) resolution process making caching transparent on most fields except for a metadata flag denoting the field as cached. More details on our motivation for creating this [here](https://stackshare.io/posts/introducing-graphql-cache).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-cache'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install graphql-cache
```

## Setup

1. Use GraphQL Cache as a plugin in your schema.

  ```ruby
  class MySchema < GraphQL::Schema
    query Types::Query

    use GraphQL::Cache
  end
  ```
2. Add the custom caching field class to your base object class. This adds the `cache` metadata key when defining fields.
  ```ruby
  module Types
    class Base < GraphQL::Schema::Object
      field_class GraphQL::Cache::Field
    end
  end
  ```

## Configuration

GraphQL Cache can be configured in an initializer:

```ruby
# config/initializers/graphql_cache.rb

GraphQL::Cache.configure do |config|
  config.namespace = 'GraphQL::Cache' # Cache key prefix for keys generated by graphql-cache
  config.cache     = Rails.cache      # The cache object to use for caching
  config.logger    = Rails.logger     # Logger to receive cache-related log messages
  config.expiry    = 5400             # 90 minutes (in seconds)
  config.force     = false            # Cache override, when true no caching takes place
end
```

## Usage

Any object, list, or connection field can be cached by simply adding `cache: true` to the field definition:

```ruby
field :calculated_field, Int, cache: true
```

### Custom Expirations

By default all keys will have an expiration of `GraphQL::Cache.expiry` which defaults to 90 minutes.  If you want to set a field-specific expiration time pass a hash to the `cache` parameter like this:

```ruby
field :calculated_field, Int, cache: { expiry: 10800 } # expires key after 180 minutes
```

### Custom cache keys

GraphQL Cache generates a cache key using the context of a query during execution. A custom key can be included to implement versioned caching as well. By providing a `:key` value to the cache config hash on a field definition.  For example, to use a custom method that returns the cache key for an object use:

```ruby
field :calculated_field, Int, cache: { key: :custom_cache_key }
```

With this configuration the cache key used for this resolved value will use the result of the method `custom_cache_key` called on the parent object.

### Forcing the cache

It is possible to force graphql-cache to resolve and write all cached fields to cache regardless of the presence of a given key in the cache store.  This will effectively "renew" any existing cached expirations and warm any that don't exist. To use forced caching, add a value to `:force_cache` in the query context:

```ruby
MySchema.execute('{ company(id: 123) { cachedField }}', context: { force_cache: true })
```

This will resolve all cached fields using the field's resolver and write them to cache without first reading the value at their respective cache keys.  This is useful for structured cache warming strategies where the cache expiration needs to be updated when a warming query is made.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stackshareio/graphql-cache. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the graphql-cache project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/stackshareio/graphql-cache/blob/master/CODE_OF_CONDUCT.md).
