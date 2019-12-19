# frozen_string_literal: true

module GraphQL
  module Cache
    # Represents the caching resolver that wraps the existing resolver proc
    class Resolver
      attr_accessor :type, :field, :orig_resolve_proc

      def initialize(type, field)
        @type  = type
        @field = field
      end

      def call(obj, args, ctx)
        resolve_proc = proc { field.resolve_proc.call(obj, args, ctx) }
        key = cache_key(obj, args, ctx)
        metadata = field.metadata[:cache]

        if field.connection?
          Resolvers::ConnectionResolver.new(resolve_proc, key, metadata).call(
            args: args, field: field, parent: obj, context: ctx, force_cache: ctx[:force_cache]
          )
        else
          Resolvers::ScalarResolver.new(resolve_proc, key, metadata).call(force_cache: ctx[:force_cache])
        end
      end

      protected

      # @private
      def cache_key(obj, args, ctx)
        Key.new(obj, args, type, field, ctx).to_s
      end
    end
  end
end
