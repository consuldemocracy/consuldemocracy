require "csv"

module Sensemaker
  class CsvExporter
    EXPORT_HEADERS = %w[comment-id comment_text agrees disagrees passes author-id].freeze

    attr_reader :conversation, :include_votes

    def initialize(conversation, options = {})
      raise ArgumentError,
            "conversation must be a Sensemaker::Conversation" unless conversation.is_a?(Conversation)

      @conversation = conversation
      @include_votes = options.fetch(:include_votes, true)
    end

    def export_to_csv(file_path = nil)
      file_path ||= default_file_path
      FileUtils.mkdir_p(File.dirname(file_path))

      CSV.open(file_path, "w", write_headers: true, headers: self.class::EXPORT_HEADERS) do |csv|
        export_data.each do |row|
          csv << row
        end
      end

      file_path
    end

    def export_to_string
      CSV.generate(headers: true) do |csv|
        csv << self.class::EXPORT_HEADERS
        export_data.each do |row|
          csv << row
        end
      end
    end

    def self.provide_defaults_for_zero_vote_comments(csv_file_path)
      return unless File.exist?(csv_file_path)

      rows = []
      defaults_applied = false
      comments_count = 0

      CSV.foreach(csv_file_path, headers: true) do |row|
        comments_count += 1
        agrees = (row["agrees"] || 0).to_i
        disagrees = (row["disagrees"] || 0).to_i
        passes = (row["passes"] || 0).to_i

        if agrees.zero? && disagrees.zero? && passes.zero?
          row["agrees"] = "0" if row["agrees"].nil?
          row["disagrees"] = "0" if row["disagrees"].nil?
          row["passes"] = "1"
          defaults_applied = true
        end

        rows << row
      end

      if defaults_applied
        FileUtils.cp(csv_file_path, "#{csv_file_path}.unfiltered")
        headers = CSV.read("#{csv_file_path}.unfiltered", headers: true).headers
        headers = (headers + %w[agrees disagrees passes]).uniq
        CSV.open(csv_file_path, "w", write_headers: true, headers: headers) do |csv|
          rows.each { |row| csv << headers.map { |header| row[header] } }
        end
        Rails.logger.debug(
          "Default vote passes applied for zero-vote comments in #{csv_file_path}"
        )
      else
        Rails.logger.debug("All comments have votes, no defaults required")
      end

      comments_count
    end

    private

      def export_data
        data = []
        data.concat(comments_as_rows)
        data
      end

      def comments_as_rows
        items = @conversation.comments

        items.map do |item|
          [
            item_id(item),
            item.body,
            item.cached_votes_up || 0,
            item.cached_votes_down || 0,
            item_votes_neutral(item),
            item.user_id
          ]
        end
      end

      def item_id(item)
        if item.is_a?(CommentLikeItem)
          "item_#{item.id}"
        else
          "comment_#{item.id}"
        end
      end

      def item_votes_neutral(item)
        total = item.cached_votes_total || 0
        up = item.cached_votes_up || 0
        down = item.cached_votes_down || 0
        [total - up - down, 0].max
      end

      def default_file_path
        data_folder = Sensemaker::Paths.sensemaker_data_folder
        File.join(data_folder, "sensemaker-input.csv")
      end
  end
end
