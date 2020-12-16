class Legislation::Process < ApplicationRecord
  include ActsAsParanoidAliases
  include Taggable
  include Milestoneable
  include Imageable
  include Documentable
  include SDG::Relatable
  include Searchable

  acts_as_paranoid column: :hidden_at
  acts_as_taggable_on :customs

  attribute :background_color, default: "#e7f2fc"
  attribute :font_color, default: "#222222"

  translates :title,              touch: true
  translates :summary,            touch: true
  translates :description,        touch: true
  translates :additional_info,    touch: true
  translates :milestones_summary, touch: true
  translates :homepage,           touch: true
  include Globalizable

  PHASES_AND_PUBLICATIONS = %i[homepage_phase draft_phase debate_phase allegations_phase
                               proposals_phase draft_publication result_publication].freeze

  CSS_HEX_COLOR = /\A#?(?:[A-F0-9]{3}){1,2}\z/i.freeze

  has_many :draft_versions, -> { order(:id) },
    foreign_key: "legislation_process_id",
    inverse_of:  :process,
    dependent:   :destroy
  has_one :final_draft_version, -> { where final_version: true, status: "published" },
    class_name:  "Legislation::DraftVersion",
    foreign_key: "legislation_process_id",
    inverse_of:  :process
  has_many :questions, -> { order(:id) },
    foreign_key: "legislation_process_id",
    inverse_of:  :process,
    dependent:   :destroy
  has_many :proposals, -> { order(:id) },
    foreign_key: "legislation_process_id",
    inverse_of:  :process,
    dependent:   :destroy

  validates_translation :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :debate_start_date, presence: true, if: :debate_end_date?
  validates :debate_end_date, presence: true, if: :debate_start_date?
  validates :draft_start_date, presence: true, if: :draft_end_date?
  validates :draft_end_date, presence: true, if: :draft_start_date?
  validates :allegations_start_date, presence: true, if: :allegations_end_date?
  validates :allegations_end_date, presence: true, if: :allegations_start_date?
  validates :proposals_phase_end_date, presence: true, if: :proposals_phase_start_date?
  validate :valid_date_ranges
  validates :background_color, format: { allow_blank: true, with: CSS_HEX_COLOR }
  validates :font_color, format: { allow_blank: true, with: CSS_HEX_COLOR }

  class << self; undef :open; end
  scope :open, -> { where("start_date <= ? and end_date >= ?", Date.current, Date.current) }
  scope :active, -> { where("end_date >= ?", Date.current) }
  scope :past, -> { where("end_date < ?", Date.current) }

  scope :published, -> { where(published: true) }

  def self.not_in_draft
    where("draft_phase_enabled = false or (draft_start_date IS NOT NULL and
           draft_end_date IS NOT NULL and (draft_start_date > ? or
           draft_end_date < ?))", Date.current, Date.current)
  end

  def homepage_phase
    Legislation::Process::Phase.new(start_date, end_date, homepage_enabled)
  end

  def draft_phase
    Legislation::Process::Phase.new(draft_start_date, draft_end_date, draft_phase_enabled)
  end

  def debate_phase
    Legislation::Process::Phase.new(debate_start_date, debate_end_date, debate_phase_enabled)
  end

  def allegations_phase
    Legislation::Process::Phase.new(allegations_start_date,
                                    allegations_end_date, allegations_phase_enabled)
  end

  def proposals_phase
    Legislation::Process::Phase.new(proposals_phase_start_date,
                                    proposals_phase_end_date, proposals_phase_enabled)
  end

  def draft_publication
    Legislation::Process::Publication.new(draft_publication_date, draft_publication_enabled)
  end

  def result_publication
    Legislation::Process::Publication.new(result_publication_date, result_publication_enabled)
  end

  def enabled_phases?
    PHASES_AND_PUBLICATIONS.any? { |process| send(process).enabled? }
  end

  def enabled_phases_and_publications_count
    PHASES_AND_PUBLICATIONS.count { |process| send(process).enabled? }
  end

  def total_comments
    questions.sum(:comments_count) + draft_versions.map(&:total_comments).sum
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

  def searchable_translations_definitions
    {
      title       => "A",
      summary     => "C",
      description => "D"
    }
  end

  def searchable_values
    searchable_globalized_values
  end

  def self.search(terms)
    pg_search(terms)
  end

  private

    def valid_date_ranges
      if end_date && start_date && end_date < start_date
        errors.add(:end_date, :invalid_date_range)
      end
      if debate_end_date && debate_start_date && debate_end_date < debate_start_date
        errors.add(:debate_end_date, :invalid_date_range)
      end
      if draft_end_date && draft_start_date && draft_end_date < draft_start_date
        errors.add(:draft_end_date, :invalid_date_range)
      end
      if allegations_end_date && allegations_start_date &&
         allegations_end_date < allegations_start_date
        errors.add(:allegations_end_date, :invalid_date_range)
      end
    end
end
