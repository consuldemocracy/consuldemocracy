class RelatedContentScore < ActiveRecord::Base
  belongs_to :related_content, touch: true, counter_cache: :related_content_scores_count

  validates :user_id, presence: true
  validates :related_content_id, presence: true
end
