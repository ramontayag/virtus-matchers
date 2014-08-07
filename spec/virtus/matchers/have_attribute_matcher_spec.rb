# encoding: utf-8

describe Virtus::Matchers::HaveAttributeMatcher do
  class FakeCoercer; end

  class Example
    include Virtus.model

    attribute :any
    attribute :foo, String
    attribute :bar, Array[String]
    attribute :baz, Array
    attribute :lol, DateTime, coercer: FakeCoercer
    attribute :hello, String, default: "Hello"
    attribute :hi_no_default, String
  end

  context 'when attribute is defined', 'with no type' do
    let(:matcher) { described_class.new(:any) }

    it 'should match' do
      matcher.matches?(Example).should be_true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute any'
    end
  end

  context 'when attribute is defined', 'with simple type' do
    let(:matcher) { described_class.new(:foo, String) }

    it 'should match' do
      matcher.matches?(Example).should be_true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute foo of type String'
    end
  end

  context 'when attribute is defined', 'with array type', 'and correct member type' do
    let(:matcher) { described_class.new(:bar, Array[String]) }

    it 'should match' do
      matcher.matches?(Example).should be_true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute bar of type Array[String]'
    end
  end

  context 'when attribute is defined', 'with a valid coercer' do
    let(:matcher) { described_class.new(:lol, DateTime).coerced_with(FakeCoercer) }

    it 'should match' do
      matcher.matches?(Example).should be_true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute lol of type DateTime coerced with FakeCoercer'
    end
  end

  context 'when attribute is defined', 'with invalid coercer' do
    let(:matcher) { described_class.new(:lol, DateTime).coerced_with(String) }

    it 'should not match' do
      matcher.matches?(Example).should be_false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute lol of type DateTime coerced with FakeCoercer"
    end
  end

  context 'when attribute is defined', 'with array type', 'and no member type' do
    let(:matcher) { described_class.new(:baz, Array) }

    it 'should match' do
      matcher.matches?(Example).should be_true
    end

    it 'should have a description' do
      matcher.matches?(Example)
      matcher.description.should == 'have attribute baz of type Array'
    end
  end

  context 'when attribute is defined', 'with array type', 'but wrong member type' do
    let(:matcher) { described_class.new(:bar, Array[Integer]) }

    it 'should not match' do
      matcher.matches?(Example).should be_false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute bar of type Array[Integer]"
    end
  end

  context 'when attribute is defined', 'with wrong type' do
    let(:matcher) { described_class.new(:foo, Hash) }

    it 'should not match' do
      matcher.matches?(Example).should be_false
    end

    it 'should have a failure message' do
      matcher.matches?(Example)
      matcher.failure_message.should == "expected #{Example} to have attribute foo of type Hash"
    end
  end

  context 'when attribute is not defined' do
    let(:matcher) { described_class.new(:baz, String) }

    it 'should not match' do
      matcher.matches?(Example).should be_false
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
end
