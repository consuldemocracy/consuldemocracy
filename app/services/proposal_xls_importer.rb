class ProposalXLSImporter
  def initialize(file_url)
    @xlsx = Roo::Excelx.new(file_url)
  end

  def import
    @xlsx.each_row_streaming(offset: 1) do |row|
      district_data = get_row_data(row)
      p district_data
    end
  end

  private

  def get_row_data(row)
    {
      name: row[0].try(:value),
      category_name: row[1].try(:value),
      subcategory_name: row[2].try(:value),
      title: row[3].try(:value),
      summary: row[4].try(:value),
      tags: row[5].try(:value)
    }
  end
end
