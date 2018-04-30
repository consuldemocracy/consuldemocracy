class Administrator < ActiveRecord::Base
  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  validates :user_id, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: administrators
#
#  id      :integer          not null, primary key
#  user_id :integer
#
