class Project < ActiveRecord::Base

  has_and_belongs_to_many :geozones
  has_many :design_events
  belongs_to :proposal

  accepts_nested_attributes_for :design_events

end
