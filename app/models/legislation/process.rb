class Legislation::Process < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  has_many :draft_versions, -> { order(:id) }, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_process_id'
  has_one :final_draft_version, -> { where final_version: true, status: 'published' }, class_name: 'Legislation::DraftVersion', foreign_key: 'legislation_process_id'
  has_many :questions, -> { order(:id) }, class_name: 'Legislation::Question', foreign_key: 'legislation_process_id'

  validates :title, presence: true
  validates :description, presence: true
  validates :target, presence: true
  validates :how_to_participate, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :debate_start_date, presence: true
  validates :debate_end_date, presence: true
  validates :draft_publication_date, presence: true
  validates :allegations_start_date, presence: true
  validates :allegations_end_date, presence: true
  validates :final_publication_date, presence: true
  validate :valid_date_ranges

  scope :open, -> { where("start_date <= ? and end_date >= ?", Date.current, Date.current).order('id DESC') }
  scope :next, -> { where("start_date > ?", Date.current).order('id DESC') }
  scope :past, -> { where("end_date < ?", Date.current).order('id DESC') }

  def open_phase?(phase)
    today = Date.current

    case phase
    when :debate
      today >= debate_start_date && today <= debate_end_date
    when :draft_publication
      today >= draft_publication_date
    when :allegations
      today >= allegations_start_date && today <= allegations_end_date
    when :final_version_publication
      today >= final_publication_date
    end
  end

  def show_phase?(phase)
    # show past phases even if they're finished
    today = Date.current

    case phase
    when :debate
      today >= debate_start_date
    when :draft_publication
      today >= draft_publication_date
    when :allegations
      today >= allegations_start_date
    when :final_version_publication
      today >= final_publication_date
    end
  end

  def total_comments
    questions.sum(:comments_count)
  end

  def status
    today = Date.current

    if today < start_date
      :planned
    elsif end_date < today
      :closed
    else
      :open
    end
  end

  private

    def valid_date_ranges
      errors.add(:end_date, :invalid_date_range) if end_date < start_date
      errors.add(:debate_end_date, :invalid_date_range) if debate_end_date < debate_start_date
      errors.add(:allegations_end_date, :invalid_date_range) if allegations_end_date < allegations_start_date
    end

end
