require 'test/unit'

require 'exception_notifier/rake/multi_delegator'

class MultiDelegatorTest < Test::Unit::TestCase

  def setup
    @delegate1 = []
    @delegate2 = [42]
  end

  def test_one_delegate
    delegator = ExceptionNotifier::Rake::MultiDelegator.new([@delegate1])
    result = delegator.push(42)
    assert_equal [42], @delegate1
    assert_equal [42], result
  end

  def test_multiple_delegates
    delegator = ExceptionNotifier::Rake::MultiDelegator.new([@delegate1, @delegate2])
    result = delegator.push(43)
    assert_equal [43], result
    assert_equal [43], @delegate1
    assert_equal [42, 43], @delegate2
  end

  def test_multiple_delegates_block_argument
    delegator = ExceptionNotifier::Rake::MultiDelegator.new([@delegate1, @delegate2])
    result = delegator.map! do |e| e + 1 end
    assert_equal [], result
    assert_equal [], @delegate1
    assert_equal [43], @delegate2
  end
end
