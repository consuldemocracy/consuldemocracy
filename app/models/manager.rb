class Manager < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  validates :user_id, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: managers
#
#  id      :integer          not null, primary key
#  user_id :integer
#
