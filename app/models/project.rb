class Project < ActiveRecord::Base

  has_and_belongs_to_many :geozones
  has_one :proposal

end
