# frozen_string_literal: true

class LogParser
  module CLI
    def output_to_cli(total_views:, unique_views:)
      <<-HEREDOC
        #{puts 'List of Webpages with Most Page Views.'}
        #{build_output(total_views)}
        #{puts}
        #{puts 'List of Webpages with Most Unique Page Views.'}
        #{build_output(unique_views)}
      HEREDOC
    end

    private

    def build_output(visits)
      visits.each_with_index do |visit, index|
        visit_array = visit.to_a.first
        page = visit_array.first
        count = visit_array.last
        puts "#{index + 1}: #{page} #{count}"
      end
    end
  end
end
