# encoding: utf-8
require 'spec_helper'

RSpec.describe Virtus::Matchers::HaveAttributeMatcher do
  class FakeCoercer; end

  class Example
    include Virtus.model

    attribute :any
    attribute :foo, String
    attribute :bar, Array[String]
    attribute :array_attribute_with_default, Array[String], default: ["hello", "world"]
    attribute :baz, Array
    attribute :lol, DateTime, coercer: FakeCoercer
    attribute :hello, String, default: "Hello"
    attribute :hi_no_default, String
    attribute :strict, String, strict: true
    attribute :lenient, String
  end

  context 'when attribute is defined, with no type' do
    let(:matcher) { described_class.new(:any) }

    it 'should match' do
      matcher.matches?(Example).should be true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute any'
    end
  end

  context 'when attribute is defined, with String type' do
    let(:matcher) { described_class.new(:foo, String) }

    it 'should match' do
      matcher.matches?(Example).should be true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute foo of type String'
    end
  end

  context 'when attribute is defined, with array type, and correct member type' do
    let(:matcher) { described_class.new(:bar, Array[String]) }

    it 'should match' do
      matcher.matches?(Example).should be true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute bar of type Array[String]'
    end
  end

  context 'when attribute is defined, with array type, with default' do
    let(:matcher) do
      described_class.
        new(:array_attribute_with_default, Array[String]).
        with_default(array_default)
    end
    let(:array_default) { ['hello', 'world'] }

    it 'should match' do
      matcher.matches?(Example).should be true
    end

    context 'different array default' do
      let(:array_default) { ['different', 'default'] }
      it 'should not match' do
        matcher.matches?(Example).should be false
      end
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == "have attribute array_attribute_with_default of type Array[String] with default \"[\"hello\", \"world\"]\""
    end
  end

  context 'when attribute is defined, with a valid coercer' do
    let(:matcher) { described_class.new(:lol, DateTime).coerced_with(FakeCoercer) }

    it 'should match' do
      matcher.matches?(Example).should be true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute lol of type DateTime coerced with FakeCoercer'
    end
  end

  context 'when attribute is defined, with invalid coercer' do
    let(:matcher) { described_class.new(:lol, DateTime).coerced_with(String) }

    it 'should not match' do
      matcher.matches?(Example).should be false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute lol of type DateTime coerced with FakeCoercer"
    end
  end

  context 'when attribute is defined, with array type, and no member type' do
    let(:matcher) { described_class.new(:baz, Array) }

    it 'should match' do
      matcher.matches?(Example).should be true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute baz of type Array'
    end
  end

  context 'when attribute is defined, with array type, but wrong member type' do
    let(:matcher) { described_class.new(:bar, Array[Integer]) }

    it 'should not match' do
      matcher.matches?(Example).should be false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute bar of type Array[Integer]"
    end
  end

  context 'when attribute is defined, with wrong type' do
    let(:matcher) { described_class.new(:foo, Hash) }

    it 'should not match' do
      matcher.matches?(Example).should be false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute foo of type Hash"
    end
  end

  context 'when attribute is not defined' do
    let(:matcher) { described_class.new(:baz, String) }

    it 'should not match' do
      matcher.matches?(Example).should be false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute baz of type String"
    end
  end

  context 'checking for default' do
    context "when default matches expected default" do
      let(:matcher) { described_class.new(:hello, String).with_default("Hello") }

      it 'matches' do
        expect(matcher.matches?(Example)).to be true
      end
    end

    context "when default does not match the expected default" do
      let(:matcher) { described_class.new(:hello, String).with_default("Hala") }

      it 'does not match' do
        expect(matcher.matches?(Example)).to be false
      end
    end

    context "there is an expected default, but none is set" do
      let(:matcher) do
        described_class.new(:hi_no_default, String).with_default("Hello")
      end

      it 'does not match' do
        expect(matcher.matches?(Example)).to be false
      end
    end

    it 'has a description' do
      matcher = described_class.new(:hello, String).with_default("Hello")
      matcher.matches?(Example)
      expect(matcher.description).to eq 'have attribute hello of type String with default "Hello"'
    end
  end

  context 'checking for strict' do
    context "it matches expected strictness" do
      let(:matcher) { described_class.new(:strict, String).strict }

      it 'matches' do
        expect(matcher.matches?(Example)).to be true
      end
    end

    context "it does not match the expected strictness" do
      let(:matcher) { described_class.new(:lenient, String).strict }

      it 'does not match' do
        expect(matcher.matches?(Example)).to be false
      end
    end

    context "spec does not specify strictness" do
      it "matches" do
        matcher = described_class.new(:strict, String)
        expect(matcher.matches?(Example)).to be true

        matcher = described_class.new(:lenient, String)
        expect(matcher.matches?(Example)).to be true
      end
    end

    it 'has a description' do
      matcher = described_class.new(:lenient, String).strict
      matcher.matches?(Example)
      expect(matcher.description).to eq 'have attribute lenient of type String and is strict'
    end
  end
end
