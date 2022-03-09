module JsonExporter
  def to_json_file(filename)
    data = []
    model.find_each { |record| data << json_values(record) }
    File.open(filename, "w") { |file| file.write(data.to_json) }
  end

  private

    def strip_tags(html_string)
      ActionView::Base.full_sanitizer.sanitize(html_string)
    end

    def model
      raise "This method must be implemented in class #{self.class.name}"
    end

    def json_values(record)
      raise "This method must be implemented in class #{self.class.name}"
    end
end
