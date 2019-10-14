module ConsulAssemblies
  class Assembly < ActiveRecord::Base

    has_many :meetings
    belongs_to :geozone
    belongs_to :assembly_type



    validates :name, presence: true
    validates :geozone, presence: true

  end
end
