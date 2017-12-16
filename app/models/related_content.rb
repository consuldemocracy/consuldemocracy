class RelatedContent < ActiveRecord::Base
  RELATED_CONTENTS_REPORT_THRESHOLD = Setting['related_contents_report_threshold'].to_i
  RELATIONABLE_MODELS = %w{proposals debates}.freeze

  belongs_to :parent_relationable, polymorphic: true
  belongs_to :child_relationable, polymorphic: true
  has_one :opposite_related_content, class_name: 'RelatedContent', foreign_key: :related_content_id

  validates :parent_relationable_id, presence: true
  validates :parent_relationable_type, presence: true
  validates :child_relationable_id, presence: true
  validates :child_relationable_type, presence: true
  validates :parent_relationable_id, uniqueness: { scope: [:parent_relationable_type, :child_relationable_id, :child_relationable_type] }

  after_create :create_opposite_related_content, unless: proc { opposite_related_content.present? }
  after_destroy :destroy_opposite_related_content, if: proc { opposite_related_content.present? }

  scope :not_hidden, -> { where('times_reported <= ?', RELATED_CONTENTS_REPORT_THRESHOLD) }

  def hidden_by_reports?
    times_reported > RELATED_CONTENTS_REPORT_THRESHOLD
  end

  private

  def create_opposite_related_content
    related_content = RelatedContent.create!(opposite_related_content: self, parent_relationable: child_relationable, child_relationable: parent_relationable)
    self.opposite_related_content = related_content
  end

  def destroy_opposite_related_content
    opposite_related_content.destroy
  end
end
