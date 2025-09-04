require "csv"

module Sensemaker
  class CsvExporter
    attr_reader :resource, :include_votes

    def initialize(resource, options = {})
      @resource = resource
      @include_votes = options.fetch(:include_votes, true)
    end

    def export_to_csv(file_path = nil)
      file_path ||= default_file_path
      FileUtils.mkdir_p(File.dirname(file_path))

      CSV.open(file_path, "w", write_headers: true, headers: csv_headers) do |csv|
        export_data.each do |row|
          csv << row
        end
      end

      file_path
    end

    def export_to_string
      CSV.generate(headers: true) do |csv|
        csv << csv_headers
        export_data.each do |row|
          csv << row
        end
      end
    end

    private

      def csv_headers
        %w[comment_id comment_text agrees disagrees passes]
      end

      def export_data
        data = []
        data.concat(comments_as_rows)
        data
      end

      def comments_as_rows
        resource.comments.includes(:user)
                .where(hidden_at: nil)
                .map do |comment|
          [
            "comment_#{comment.id}",
            comment.body,
            comment.cached_votes_up || 0,
            comment.cached_votes_down || 0,
            comment_votes_neutral(comment)
          ]
        end
      end

      def comment_votes_neutral(comment)
        total = comment.cached_votes_total || 0
        up = comment.cached_votes_up || 0
        down = comment.cached_votes_down || 0
        [total - up - down, 0].max
      end

      def default_file_path
        data_folder = Sensemaker::JobRunner.sensemaker_data_folder
        File.join(data_folder, "sensemaker-input.csv")
      end

      def self.export(resource, options = {})
        new(resource, options).export_to_csv
      end
  end
end
