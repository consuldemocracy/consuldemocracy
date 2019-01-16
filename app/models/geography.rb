class Geography < ActiveRecord::Base

  include Documentable
  documentable max_documents_allowed: 1,
               max_file_size: 6.megabytes,
               accepted_content_types: [ "application/json", "text/plain" ]

  validates :name, presence: true
  validates :color, presence: true
  validates_with GeojsonFormat

  has_many :headings, class_name: Budget::Heading

  def self.active_headings_geographies
    active_headings = {}
    Budget.current.headings.each do |active_heading|
      if active_heading.geography
         active_headings[active_heading.geography_id] = active_heading.id
      end
    end
    active_headings
  end

end

