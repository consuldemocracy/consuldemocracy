module CsvExporter
  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      records.each do |record|
        comments = record.comments.sort_by(&:created_at)

        if comments.any?
          comments.each { |comment| csv << csv_values(record, comment) }
        else
          csv << csv_values(record)
        end
      end
    end
  end

  private

    def csv_values(record, comment = nil)
      record_csv_values(record) + comment_csv_values(comment)
    end

    def headers
      model_headers + comment_csv_headers
    end

    def record_csv_values(record)
      raise "This method must be implemented in class #{self.class.name}"
    end

    def model_headers
      raise "This method must be implemented in class #{self.class.name}"
    end

    def comment_csv_headers
      [
        I18n.t("admin.comments.index.id"),
        I18n.t("admin.comments.index.author"),
        I18n.t("admin.comments.index.content"),
        Comment.human_attribute_name(:parent_id),
        Comment.human_attribute_name(:created_at)
      ].map { |name| comment_header(name) }
    end

    def comment_csv_values(comment)
      return empty_comment_csv_values unless comment

      [
        comment.id.to_s,
        comment.author&.email.to_s,
        comment.body,
        comment.parent_id.to_s,
        I18n.l(comment.created_at, format: :datetime)
      ]
    end

    def empty_comment_csv_values
      Array.new(comment_csv_headers.size, "")
    end

    def comment_header(name)
      "#{Comment.model_name.human} #{name}"
    end
end
