class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable

  apply_simple_captcha

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone
  belongs_to :administrator
  has_many :valuation_assignments, dependent: :destroy
  has_many :valuators, through: :valuation_assignments

  validates :title, presence: true
  validates :author, presence: true
  validates :description, presence: true

  validates :title, length: { in: 4..SpendingProposal.title_max_length }
  validates :description, length: { maximum: SpendingProposal.description_max_length }
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  scope :without_admin, -> { where(administrator_id: nil) }
  scope :without_valuators, -> { where(valuation_assignments_count: 0) }
  scope :valuating, -> { where("valuation_assignments_count > 0 AND valuation_finished = ?", false) }
  scope :valuation_finished, -> { where(valuation_finished: true) }

  scope :for_render, -> { includes(:geozone, administrator: :user, valuators: :user) }

  def description
    super.try :html_safe
  end

  def self.search(params, current_filter)
    results = self
    results = results.by_geozone(params[:geozone_id])             if params[:geozone_id].present?
    results = results.by_administrator(params[:administrator_id]) if params[:administrator_id].present?
    results = results.send(current_filter)                        if current_filter.present?
    results.for_render
  end

  def self.by_geozone(geozone)
    if geozone == 'all'
      where(geozone_id: nil)
    else
      where(geozone_id: geozone.presence)
    end
  end

  def self.by_administrator(administrator)
    where(administrator_id: administrator.presence)
  end

  def feasibility
    case feasible
    when true
      "feasible"
    when false
      "not_feasible"
    else
      "undefined"
    end
  end

end
