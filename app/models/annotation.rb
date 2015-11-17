class Annotation < ActiveRecord::Base
  serialize :ranges, Array

  belongs_to :proposal
end