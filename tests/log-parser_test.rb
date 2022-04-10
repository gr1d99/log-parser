# frozen_string_literal: true

require 'minitest/autorun'

require_relative '../log-parser'

class LogParserTest < MiniTest::Test
  def test_sets_filename_correctly
    log_file = './tests/webserver.log'
    parser = LogParser.new(log_file)

    assert parser.filename.equal?(log_file)
  end

  def test_parses_correct_total_views
    log_file = './tests/webserver.log'
    result = LogParser.call(log_file)

    total_views = result[:total_views]

    assert_includes(total_views, { '/help_page/1': :"3 Visits" })
    assert_includes(total_views, { '/contact': '1 Visit' })
    assert_includes(total_views, { home: :"2 Visits" })
  end

  def test_parses_correct_unique_views
    log_file = './tests/webserver.log'
    result = LogParser.call(log_file)

    unique_views = result[:total_views]

    assert_includes(unique_views, { '/help_page/1': :'2 Unique visits' })
    assert_includes(unique_views, { '/contact': :'1 Unique visits' })
    assert_includes(unique_views, { home: '2 Unique visits' })
  end

  def test_assert_sorts_total_views_starting_with_most_views
    log_file = './tests/webserver.log'
    result = LogParser.call(log_file)
    total_views = result[:total_views]

    assert_equal(total_views[0], { '/help_page/1': :"3 Visits" })
    assert_equal(total_views[1], { home: :"2 Visits" })
    assert_equal(total_views[2], { '/contact': '1 Visit' })
  end

  def test_assert_sorts_unique_views_starting_with_most_views
    log_file = './tests/webserver.log'
    result = LogParser.call(log_file)

    unique_views = result[:unique_views]

    assert_equal(unique_views[0], { '/help_page/1': :'2 Unique visits' })
    assert_equal(unique_views[2], { home: '2 Unique visits' })
    assert_equal(unique_views[1], { '/contact': :'1 Unique visits' })
  end
end
