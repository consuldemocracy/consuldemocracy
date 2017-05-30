class Project < ActiveRecord::Base

  has_and_belongs_to_many :geozones
  belongs_to :proposal
  has_one :design_phase

  accepts_nested_attributes_for :design_phase

end
