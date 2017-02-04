require_relative '../helper'
require 'fluent/plugin/filter_timerange'
require 'fluent/test/driver/filter'

class TimerangeFilterTest < Test::Unit::TestCase
  include Fluent

  setup do
    Fluent::Test.setup
    @time = event_time
  end

  def create_driver(conf = '')
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::TimerangeFilter).configure(conf)
  end

  CONFIG = %[
    starttime 09:00
    endtime 21:00
  ]

  sub_test_case 'configure' do
    test "starttime and endtime parameters are set with '1970-01-01 '" do
      d = create_driver(CONFIG)
      assert_equal(Time.parse('1970-01-01 09:00:00'), d.instance.starttime)
      assert_equal(Time.parse('1970-01-01 21:00:00'), d.instance.endtime)
    end
  end

  sub_test_case 'filter_stream' do
    def filter(config, msgs)
      d = create_driver(config)
      d.run {
        msgs.each { |msg|
          @time = Time.parse(msg.slice(0..19).gsub('/', '-')).to_i
          d.feed("filter.test", @time, {'message' => msg.slice(20..-1)})
        }
      }
      d.filtered_records
    end

    def messages
      [
        "2017/01/01 08:59:59 test message 1",
        "2017/01/01 09:00:00 test message 2",
        "2017/01/01 20:59:59 test message 3",
        "2017/01/01 21:00:00 test message 4",
      ]
    end

    test 'around border' do
      filtered_records = filter(CONFIG, messages)
      assert_equal(2, filtered_records.size)
      assert_block('only In a range logs') do
        filtered_records.all? { |r|
          !r['message'].include?('test message 2') or !r['message'].include?('test message 3')
        }
      end
    end
  end
end
