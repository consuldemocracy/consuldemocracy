class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true

  validates :user_id, presence: true
  validates :followable, presence: true
end

# == Schema Information
#
# Table name: follows
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  followable_id   :integer
#  followable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
