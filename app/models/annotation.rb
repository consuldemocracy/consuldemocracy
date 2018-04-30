class Annotation < ActiveRecord::Base
  serialize :ranges, Array

  belongs_to :legacy_legislation
  belongs_to :user

  def permissions
    { update: [user_id], delete: [user_id], admin: [] }
  end
end

# == Schema Information
#
# Table name: annotations
#
#  id                    :integer          not null, primary key
#  quote                 :string
#  ranges                :text
#  text                  :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_id               :integer
#  legacy_legislation_id :integer
#
