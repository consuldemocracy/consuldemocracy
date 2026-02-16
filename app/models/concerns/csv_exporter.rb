module CsvExporter
  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      records.each { |record| csv << csv_values(record) }
    end
  end
end
