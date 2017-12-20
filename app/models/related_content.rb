class RelatedContent < ActiveRecord::Base
  RELATED_CONTENT_SCORE_THRESHOLD = Setting['related_content_score_threshold'].to_f
  RELATIONABLE_MODELS = %w{proposals debates}.freeze

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :parent_relationable, polymorphic: true, touch: true
  belongs_to :child_relationable, polymorphic: true, touch: true
  has_one :opposite_related_content, class_name: 'RelatedContent', foreign_key: :related_content_id
  has_many :related_content_scores

  validates :parent_relationable_id, presence: true
  validates :parent_relationable_type, presence: true
  validates :child_relationable_id, presence: true
  validates :child_relationable_type, presence: true
  validates :parent_relationable_id, uniqueness: { scope: [:parent_relationable_type, :child_relationable_id, :child_relationable_type] }

  after_create :create_opposite_related_content, unless: proc { opposite_related_content.present? }
  after_create :create_author_score

  scope :not_hidden, -> { where('positive_score - negative_score / LEAST(nullif(positive_score + negative_score, 0), 1) >= ?', RELATED_CONTENT_SCORE_THRESHOLD) }
  scope :not_hidden, -> { where(hidden_at: nil) }

  def score(value, user)
    score_with_opposite(value, user)
  end

  private

  def create_opposite_related_content
    related_content = RelatedContent.create!(opposite_related_content: self, parent_relationable: child_relationable, child_relationable: parent_relationable)
    self.opposite_related_content = related_content
  end

  def create_author_score
    score(1, author)
  end

  def score_with_opposite(value, user)
    RelatedContentsScore.create(user: user, related_content: self, score: value)
    RelatedContentsScore.create(user: user, related_content: opposite_related_content, score: value)
  end
end
