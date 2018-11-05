class Budget < ActiveRecord::Base

  include Measurable
  include Sluggable

  CURRENCY_SYMBOLS = %w(€ $ £ ¥).freeze

  validates :name, presence: true, uniqueness: true
  validates :phase, inclusion: { in: Budget::Phase::PHASE_KINDS }
  validates :currency_symbol, presence: true
  validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/

  has_many :investments, dependent: :destroy
  has_many :ballots, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :headings, through: :groups
  has_many :phases, class_name: Budget::Phase

  before_validation :sanitize_descriptions

  after_create :generate_phases

  scope :drafting, -> { where(phase: "drafting") }
  scope :informing, -> { where(phase: "informing") }
  scope :accepting, -> { where(phase: "accepting") }
  scope :reviewing, -> { where(phase: "reviewing") }
  scope :selecting, -> { where(phase: "selecting") }
  scope :valuating, -> { where(phase: "valuating") }
  scope :publishing_prices, -> { where(phase: "publishing_prices") }
  scope :balloting, -> { where(phase: "balloting") }
  scope :reviewing_ballots, -> { where(phase: "reviewing_ballots") }
  scope :finished, -> { where(phase: "finished") }

  scope :open, -> { where.not(phase: "finished") }

  def self.current
    where.not(phase: "drafting").order(:created_at).last
  end

  def current_phase
    phases.send(phase)
  end

  def published_phases
    phases.published.order(:id)
  end

  def description
    description_for_phase(phase)
  end

  def description_for_phase(phase)
    if phases.exists? && phases.send(phase).description.present?
      phases.send(phase).description
    else
      send("description_#{phase}").try(:html_safe)
    end
  end

  def self.title_max_length
    80
  end

  def drafting?
    phase == "drafting"
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
    valuating? || publishing_prices? || balloting_or_later?
  end

  def balloting_process?
    balloting? || reviewing_ballots?
  end

  def balloting_or_later?
    balloting_process? || finished?
  end

  def heading_price(heading)
    heading_ids.include?(heading.id) ? heading.price : -1
  end

  def translated_phase
    I18n.t "budgets.phase.#{phase}"
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

  def formatted_heading_amount_spent(heading)
    formatted_amount(amount_spent(heading))
  end

  def investments_orders
    case phase
    when 'accepting', 'reviewing'
      %w{random}
    when 'publishing_prices', 'balloting', 'reviewing_ballots'
      %w{random price}
    when 'finished'
      %w{random}
    else
      %w{random confidence_score}
    end
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

  private

  def sanitize_descriptions
    s = WYSIWYGSanitizer.new
    Budget::Phase::PHASE_KINDS.each do |phase|
      sanitized = s.sanitize(send("description_#{phase}"))
      send("description_#{phase}=", sanitized)
    end
  end

  def generate_phases
    Budget::Phase::PHASE_KINDS.each do |phase|
      Budget::Phase.create(
        budget: self,
        kind: phase,
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
