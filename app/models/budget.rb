class Budget < ApplicationRecord
  include Measurable
  include Sluggable
  include StatsVersionable
  include Reportable
  include Imageable

  translates :name, :main_link_text, :main_link_url, touch: true
  include Globalizable

  class Translation
    validate :name_uniqueness_by_budget

    def name_uniqueness_by_budget
      if Budget.joins(:translations)
               .where(name: name)
               .where.not("budget_translations.budget_id": budget_id).any?
        errors.add(:name, I18n.t("errors.messages.taken"))
      end
    end
  end

  CURRENCY_SYMBOLS = %w[€ $ £ ¥].freeze
  VOTING_STYLES = %w[knapsack approval].freeze

  validates_translation :name, presence: true
  validates_translation :main_link_url, presence: true, unless: -> { main_link_text.blank? }
  validates :phase, inclusion: { in: ->(*) { Budget::Phase::PHASE_KINDS }}
  validates :currency_symbol, presence: true
  validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
  validates :voting_style, inclusion: { in: ->(*) { VOTING_STYLES }}

  has_many :investments, dependent: :destroy
  has_many :ballots, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :headings, through: :groups
  has_many :lines, through: :ballots, class_name: "Budget::Ballot::Line"
  has_many :phases, class_name: "Budget::Phase"
  has_many :budget_administrators, dependent: :destroy
  has_many :administrators, through: :budget_administrators
  has_many :budget_valuators, dependent: :destroy
  has_many :valuators, through: :budget_valuators

  has_one :poll

  after_create :generate_phases
  accepts_nested_attributes_for :phases

  scope :published, -> { where(published: true) }
  scope :drafting,  -> { where.not(id: published) }
  scope :informing, -> { where(phase: "informing") }
  scope :accepting, -> { where(phase: "accepting") }
  scope :reviewing, -> { where(phase: "reviewing") }
  scope :selecting, -> { where(phase: "selecting") }
  scope :valuating, -> { where(phase: "valuating") }
  scope :valuating_or_later, -> { where(phase: Budget::Phase.kind_or_later("valuating")) }
  scope :publishing_prices, -> { where(phase: "publishing_prices") }
  scope :balloting, -> { where(phase: "balloting") }
  scope :reviewing_ballots, -> { where(phase: "reviewing_ballots") }
  scope :finished, -> { where(phase: "finished") }

  class << self; undef :open; end
  scope :open, -> { where.not(phase: "finished") }

  def self.current
    published.order(:created_at).last
  end

  def current_phase
    phases.send(phase)
  end

  def published_phases
    phases.published.order(:id)
  end

  def starts_at
    phases.published.first&.starts_at
  end

  def ends_at
    phases.published.last&.ends_at
  end

  def description
    description_for_phase(phase)
  end

  def description_for_phase(phase)
    if phases.exists? && phases.send(phase).description.present?
      phases.send(phase).description
    else
      send("description_#{phase}")
    end
  end

  def self.title_max_length
    80
  end

  def publish!
    update!(published: true)
  end

  def drafting?
    !published?
  end

  def informing?
    phase == "informing"
  end

  def accepting?
    phase == "accepting"
  end

  def reviewing?
    phase == "reviewing"
  end

  def selecting?
    phase == "selecting"
  end

  def valuating?
    phase == "valuating"
  end

  def publishing_prices?
    phase == "publishing_prices"
  end

  def balloting?
    phase == "balloting"
  end

  def reviewing_ballots?
    phase == "reviewing_ballots"
  end

  def finished?
    phase == "finished"
  end

  def published_prices?
    Budget::Phase::PUBLISHED_PRICES_PHASES.include?(phase)
  end

  def valuating_or_later?
    current_phase&.valuating_or_later?
  end

  def publishing_prices_or_later?
    current_phase&.publishing_prices_or_later?
  end

  def balloting_or_later?
    current_phase&.balloting_or_later?
  end

  def balloting_finished?
    balloting_or_later? && !balloting?
  end

  def single_group?
    groups.one?
  end

  def single_heading?
    single_group? && headings.one?
  end

  def heading_price(heading)
    heading_ids.include?(heading.id) ? heading.price : -1
  end

  def formatted_amount(amount)
    ActionController::Base.helpers.number_to_currency(amount,
                                                      precision: 0,
                                                      locale: I18n.locale,
                                                      unit: currency_symbol)
  end

  def formatted_heading_price(heading)
    formatted_amount(heading_price(heading))
  end

  def investments_orders
    case phase
    when "accepting", "reviewing", "finished"
      %w[random]
    when "publishing_prices", "balloting", "reviewing_ballots"
      hide_money? ? %w[random] : %w[random price]
    else
      %w[random confidence_score]
    end
  end

  def investments_filters
    [
      ("winners" if finished?),
      ("selected" if publishing_prices_or_later? && !finished?),
      ("unselected" if publishing_prices_or_later?),
      ("not_unfeasible" if valuating?),
      ("unfeasible" if valuating_or_later?)
    ].compact
  end

  def email_selected
    investments.selected.order(:id).each do |investment|
      Mailer.budget_investment_selected(investment).deliver_later
    end
  end

  def email_unselected
    investments.unselected.order(:id).each do |investment|
      Mailer.budget_investment_unselected(investment).deliver_later
    end
  end

  def has_winning_investments?
    investments.winners.any?
  end

  def investments_milestone_tags
    investments.winners.map(&:milestone_tag_list).flatten.uniq.sort
  end

  def approval_voting?
    voting_style == "approval"
  end

  def show_money?
    !hide_money?
  end

  private

    def generate_phases
      Budget::Phase::PHASE_KINDS.each do |phase|
        Budget::Phase.create(
          budget: self,
          kind: phase,
          name: I18n.t("budgets.phase.#{phase}"),
          prev_phase: phases&.last,
          starts_at: phases&.last&.ends_at || Date.current,
          ends_at: (phases&.last&.ends_at || Date.current) + 1.month
        )
      end
    end

    def generate_slug?
      slug.nil? || drafting?
    end
end
