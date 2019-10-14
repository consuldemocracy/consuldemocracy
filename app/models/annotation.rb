class Annotation < ActiveRecord::Base
  serialize :ranges, Array

  belongs_to :legacy_legislation
  belongs_to :user

  def permissions
    { update: [user_id], delete: [user_id], admin: [] }
  end
end
