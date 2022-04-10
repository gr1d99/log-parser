# frozen_string_literal: true

require_relative 'log_parser/cli'

class LogParser
  include CLI
  attr_reader :filename, :verbose

  def initialize(filename, verbose)
    @verbose = verbose
    @filename = filename
    @tracked_ips = {}
    @total_visits = {}
    @unique_visits = {}
  end

  def self.call(filename, verbose: false)
    new(filename, verbose).parse
  end

  def parse
    total_views = parse_total_visits
    unique_views = parse_unique_visits
    return output_to_cli(total_views: total_views, unique_views: unique_views) if verbose

    { total_views: total_views, unique_views: unique_views }
  end

  private

  attr_accessor :tracked_ips, :unique_visits, :total_visits

  def open_file
    file = File.join(File.expand_path(__dir__), filename)
    File.open(file)
  rescue Errno::ENOENT => e
    raise Error, e.message
  end

  def visit_parts(visit)
    parts = visit.split(' ')
    { page: parts[0], ip: parts[1] }
  end

  def track_ip(ip)
    tracked_ips[ip] = ip
  end

  def ip_tracked?(ip)
    tracked_ips.key?(ip)
  end

  def parse_total_visits
    open_file.readlines.map(&:chomp).each do |visit|
      page = visit_parts(visit)[:page]
      visited = total_visits.key? page
      if visited
        total_visits[page] += 1
        next
      end

      total_visits[page] = 1
    end
    transform_total_views
  end

  def parse_unique_visits
    open_file.readlines.map(&:chomp).each do |visit|
      parts = visit_parts(visit)
      ip = parts[:ip]
      page = parts[:page]

      visited = unique_visits.key?(page)
      same_ip = visited && ip_tracked?(ip)
      visited_with_different_ip = visited && !same_ip

      next if visited && same_ip

      if visited_with_different_ip
        new_count = unique_visits[page] += 1
        unique_visits[page] = new_count
      else
        unique_visits[page] = 1
      end
      track_ip ip
    end
    transform_unique_views
  end

  def map_visits_with_page_count(visits)
    visits.to_a.map do |key, value|
      { page: key.to_s, count: value }
    end
  end

  def sort_visit_count(visits)
    visits.sort do |a, b|
      b[:count] <=> a[:count]
    end
  end

  def transform_total_views
    result_to_a = map_visits_with_page_count(total_visits)
    sorted_result = sort_visit_count(result_to_a)
    sorted_result.map do |visit|
      page =  visit[:page]
      count = visit[:count]
      { "#{page}": "#{count} #{pluralize_visit(count)}" }
    end
  end

  def transform_unique_views
    visits_to_a = map_visits_with_page_count(unique_visits)
    sorted_result = sort_visit_count(visits_to_a)
    sorted_result.map do |visit|
      page =  visit[:page]
      count = visit[:count]
      { "#{page}": "#{count} Unique #{pluralize_visit(count)}" }
    end
  end

  def pluralize_visit(count)
    return 'Visit' if count === 1

    'Visits'
  end

  class Error < StandardError; end
end

if $PROGRAM_NAME == __FILE__
  raise LogParser::Error, 'You must provide log file as the first argument' if ARGV.length.zero?

  filename = ARGV.first
  verbose = !ARGV.last.nil?

  LogParser.call(filename, verbose: verbose)
end
