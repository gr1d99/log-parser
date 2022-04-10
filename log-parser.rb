# frozen_string_literal: true

class LogParser
  attr_accessor :filename, :tracked_ips

  def initialize(filename)
    @filename = filename
    @tracked_ips = {}
  end

  def self.call(filename)
    new(filename).parse
  end

  def parse
    total_views = parse_visits
    unique_views = parse_unique_visits
    { total_views: total_views, unique_views: unique_views }
  end

  private

  def open_file
    File.open(File.join(File.expand_path(__dir__), filename))
  end

  def visit_parts(visit)
    parts = visit.split(' ')
    { page: parts[0], ip: parts[1] }
  end

  def visited?(page, result)
    result[:views].key? page
  end

  def track_ip(ip)
    tracked_ips[ip] = ip
  end

  def ip_tracked?(ip)
    tracked_ips.key?(ip)
  end

  def parse_visits
    result = { views: {} }
    open_file.readlines.map(&:chomp).each do |visit|
      page = visit_parts(visit)[:page]
      visited = visited?(page, result)
      if visited
        result[:views][page] += 1
      else
        result[:views][page] = 1
      end
    end
    transform_total_views result
  end

  def parse_unique_visits
    result = { views: {} }
    open_file.readlines.map(&:chomp).each do |visit|
      parts = visit_parts(visit)
      ip = parts[:ip]
      page = parts[:page]

      visited = visited?(page, result)
      same_ip = visited && ip_tracked?(ip)
      visited_with_different_ip = visited && !same_ip

      next if visited && same_ip

      if visited_with_different_ip
        new_count = result[:views][page] += 1
        result[:views][page] = new_count
      else
        result[:views][page] = 1
      end
      track_ip ip
    end
    transform_unique_views(result)
  end

  def transform_total_views(result)
    result_to_a = result[:views].to_a.map do |key, value|
      { page: key.to_s, count: value }
    end

    sorted_result = result_to_a.sort do |a, b|
      b[:count] <=> a[:count]
    end

    sorted_result.map do |visit|
      page =  visit[:page]
      count = visit[:count]
      { "#{page}": "#{count} #{pluralize_visit(count)}" }
    end
  end

  def transform_unique_views(result)
    result_to_a = result[:views].to_a.map do |key, value|
      { page: key.to_s, count: value }
    end

    sorted_result = result_to_a.sort do |a, b|
      b[:count] <=> a[:count]
    end

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
end
