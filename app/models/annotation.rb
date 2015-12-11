class Annotation < ActiveRecord::Base
  serialize :ranges, Array

  belongs_to :proposal
  belongs_to :user
end