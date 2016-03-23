require 'uri'

module Bugsnag
  module Helpers
    MAX_STRING_LENGTH = 4096
    TRUNCATION = '[TRUNCATED]'

    def self.reduce_hash_size(hash)
      return {} unless hash.is_a?(Hash)
      hash.inject({}) do |h, (k,v)|
        if v.is_a?(Hash)
          h[k] = reduce_hash_size(v)
        elsif v.is_a?(Array) || v.is_a?(Set)
          h[k] = reduce_array_size(v)
        else
          h[k] = reduce_string_size(v)
        end

        h
      end
    end

    def self.reduce_string_size(text)
      return '' unless text.respond_to?(:to_s)
      val = text.to_s
      if val.length > MAX_STRING_LENGTH
        val.slice(0, MAX_STRING_LENGTH - TRUNCATION.length) + TRUNCATION
      end
      val
    end

    def self.reduce_array_size(ary)
      return [] unless ary.is_a?(Array) or ary.is_a?(Set)
      ary.map do |item|
        reduce_hash_size(item)
        case item
        when Array, Set
          reduce_array_size(item)
        when Hash
          reduce_hash_size(item)
        else
          reduce_string_size(item)
        end
      end
    end

    def self.flatten_meta_data(overrides)
      return nil unless overrides

      meta_data = overrides.delete(:meta_data)
      if meta_data.is_a?(Hash)
        overrides.merge(meta_data)
      else
        overrides
      end
    end
  end
end
