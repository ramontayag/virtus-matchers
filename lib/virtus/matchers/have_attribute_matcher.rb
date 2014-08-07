# encoding: utf-8

module Virtus
  module Matchers
    class HaveAttributeMatcher
      def initialize(name, type = nil)
        @name = name
        @type = type
      end

      def coerced_with(custom_coercer)
        @custom_coercer = custom_coercer
        self
      end

      def with_default(expected_default)
        @expected_default = expected_default
        self
      end

      def strict
        @expected_strict = true
        self
      end

      def matches?(klass)
        @klass = klass
        @attribute = @klass.attribute_set[@name]
        return false unless @attribute

        if @type.class == Array
          return @attribute.primitive == Array &&
            @attribute.options[:member_type].primitive == @type.first
        end

        valid_type && valid_coercer && valid_default && matches_strict
      end

      def description
        type = @type.class == Array ? "Array#{@type}" : @type
        str = "have attribute #{@name}"
        str += " of type #{type}#{coercer_description}" unless @type.nil?
        str += " with default \"#{@expected_default}\"" if @expected_default
        str += " and is strict" if @expected_strict
        str
      end

      def failure_message
        "expected #{@klass} to #{description}"
      end

      private

      def matches_strict
        !@expected_strict || @attribute.strict?
      end

      def valid_default
        @expected_default.nil? || @attribute.default_value.value == @expected_default
      end

      def valid_type
        @type.nil? || @attribute.primitive == @type
      end

      def valid_coercer
        @custom_coercer.nil? || @custom_coercer == @attribute.coercer
      end

      def coercer_description
        @custom_coercer && " coerced with #{@attribute.coercer}"
      end
    end

    def have_attribute(name, type = nil)
      HaveAttributeMatcher.new(name, type)
    end
  end
end
