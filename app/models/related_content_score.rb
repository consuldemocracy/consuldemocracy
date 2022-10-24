class RelatedContentScore < ApplicationRecord
  SCORES = { POSITIVE: 1, NEGATIVE: -1 }.freeze

  belongs_to :related_content, touch: true, counter_cache: :related_content_scores_count
  belongs_to :user

  validates :user, presence: true
  validates :related_content, presence: true
  validates :related_content_id, uniqueness: { scope: [:user_id] }
end

# == Schema Information
#
# Table name: related_content_scores
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  related_content_id :integer
#  value              :integer
#
