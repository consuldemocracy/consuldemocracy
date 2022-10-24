class Moderator < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, to: :user

  validates :user_id, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: moderators
#
#  id      :integer          not null, primary key
#  user_id :integer
#
