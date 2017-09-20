class Poll::Recount < ActiveRecord::Base

  VALID_ORIGINS = %w{web booth}

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :booth_assignment
  belongs_to :officer_assignment

  validates :author, presence: true
  validates :origin, inclusion: {in: VALID_ORIGINS}

  scope :by_author, ->(author_id) { where(author_id: author_id) }

  # Create proc to maximize DRYness
  proc ||= Proc.new {}

  before_save :update_null_amount_log, if: proc {
    null_amount_changed? && null_amount_was.present?
  }

  before_save :update_total_amount_log, if: proc {
    total_amount_changed? && total_amount_was.present?
  }

  before_save :update_white_amount_log, if: proc {
    white_amount_changed? && white_amount_was.present?
  }

  def update_logs
    self.officer_assignment_id_log += ":#{officer_assignment_id_was.to_s}"
    self.author_id_log += ":#{author_id_was.to_s}"
  end

  def update_null_amount_log
    self.null_amount_log += ":#{null_amount_was.to_s}"
    update_logs
  end

  def update_total_amount_log
    self.total_amount_log += ":#{total_amount_was.to_s}"
    update_logs
  end

  def update_white_amount_log
    self.white_amount_log += ":#{white_amount_was.to_s}"
    update_logs
  end
end
