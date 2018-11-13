class Geography < ActiveRecord::Base

  include Documentable
  documentable max_documents_allowed: 1,
               max_file_size: 6.megabytes,
               accepted_content_types: [ "application/json", "text/plain" ]

  validates :name, presence: true
  validates_with GeojsonFormat

  has_many :headings

end

