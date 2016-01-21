class ProposalXLSImporter
  def initialize(file_url)
    @xlsx = Roo::Excelx.new(file_url)
  end

  def import
    ActiveRecord::Base.transaction do
      @xlsx.each_row_streaming(offset: 1) do |row|
        data = get_row_data(row)
        proposal_data = ProposalData.new(data)
        proposal_data.parse!
        create_proposal(proposal_data.to_attributes)
      end
    end
  end

  private

  def get_row_data(row)
    {
      district_name: row[0].try(:value),
      category_name: row[1].try(:value),
      subcategory_name: row[2].try(:value),
      title: row[3].try(:value),
      summary: row[4].try(:value),
      tags: row[5].try(:value)
    }
  end

  def create_proposal(attrs)
    admin = Administrator.first
    responsible_name = "Ajuntament"

    proposal = Proposal.create(attrs.merge!({ 
      author_id: admin.id,
      responsible_name: responsible_name,
      official: true,
      terms_of_service: '1'
    }))
  end

  class ProposalData
    def initialize(data)
      @data = data
    end

    def parse!
      parse_district_name
      parse_category_name
      parse_subcategory_name
    end

    def to_attributes
      {
        district: @data[:district_id],
        title: @data[:title],
        summary: @data[:summary],
        category_id: @data[:category_id],
        subcategory_id: @data[:subcategory_id],
        tag_list: @data[:tags]
      }
    end

    private

    def parse_district_name
      district = Proposal::DISTRICTS.detect { |district| district[0] == @data[:district_name] }
      @data[:district_id] = district[1]
    end

    def parse_category_name
      match_data = @data[:category_name].match(/(?:(\d).?)+ (.*)/)
      position =  match_data[1]
      name =  match_data[2]
      category = Category.where('name like ?', "%#{name}%").first
      if category.nil?
        category = Category.create(name: { ca: name, es: name, en: name }, description: { ca: "", es: "", en: "" }, position: position)
      end
      @data[:category_id] = category.id
    end

    def parse_subcategory_name
      match_data = @data[:subcategory_name].match(/(?:(\d).(\d)?)+ (.*)/)
      category_position = match_data[1]
      position =  match_data[2]
      name =  match_data[3]
      subcategory = Subcategory.where('name like ?', "%#{name}%").first
      if subcategory.nil?
        category = Category.where(position: category_position).first
        subcategory = Subcategory.create(name: { ca: name, es: name, en: name }, description: { ca: "", es: "", en: "" }, position: position, category_id: category.id)
      end
      @data[:subcategory_id] = subcategory.id
    end
  end
end
