class RelatedContentScore < ApplicationRecord
  SCORES = { POSITIVE: 1, NEGATIVE: -1 }.freeze

  belongs_to :related_content, touch: true, counter_cache: :related_content_scores_count
  belongs_to :user

  validates :user, presence: true
  validates :related_content, presence: true
  validates :related_content_id, uniqueness: { scope: [:user_id] }
end
