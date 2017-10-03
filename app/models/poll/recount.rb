class Poll::Recount < ActiveRecord::Base

  VALID_ORIGINS = %w{web booth letter}.freeze

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :booth_assignment
  belongs_to :officer_assignment

  validates :author, presence: true
  validates :origin, inclusion: {in: VALID_ORIGINS}

  scope :web,    -> { where(origin: 'web') }
  scope :booth,  -> { where(origin: 'booth') }
  scope :letter, -> { where(origin: 'letter') }

  scope :by_author, ->(author_id) { where(author_id: author_id) }

  before_save :update_logs

  def update_logs
    amounts_changed = false

    [:white, :null, :total].each do |amount|
      next unless send("#{amount}_amount_changed?") && send("#{amount}_amount_was").present?
      self["#{amount}_amount_log"] += ":#{send("#{amount}_amount_was")}"
      amounts_changed = true
    end

    update_officer_author if amounts_changed
  end

  def update_officer_author
    self.officer_assignment_id_log += ":#{officer_assignment_id_was}"
    self.author_id_log += ":#{author_id_was}"
  end
end
