class Annotation < ActiveRecord::Base
  serialize :ranges, Array

  belongs_to :legislation
  belongs_to :user
end