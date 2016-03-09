class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable
  include Taggable

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

  scope :valuation_open,         -> { where(valuation_finished: false) }
  scope :without_admin,          -> { valuation_open.where(administrator_id: nil) }
  scope :managed,                -> { valuation_open.where(valuation_assignments_count: 0).where("administrator_id IS NOT ?", nil) }
  scope :valuating,              -> { valuation_open.where("valuation_assignments_count > 0 AND valuation_finished = ?", false) }
  scope :valuation_finished,     -> { where(valuation_finished: true) }

  scope :by_admin,    -> (admin)    { where(administrator_id: admin.presence) }
  scope :by_tag,      -> (tag_name) { tagged_with(tag_name) }
  scope :by_valuator, -> (valuator) { where("valuation_assignments.valuator_id = ?", valuator.presence).joins(:valuation_assignments) }

  scope :for_render,             -> { includes(:geozone, administrator: :user, valuators: :user) }

  def description
    super.try :html_safe
  end

  def self.filter_params(params)
    params.select{|x,_| %w{geozone_id administrator_id tag_name valuator_id}.include? x.to_s }
  end

  def self.search(params, current_filter)
    results = self
    results = results.by_geozone(params[:geozone_id])             if params[:geozone_id].present?
    results = results.by_admin(params[:administrator_id])         if params[:administrator_id].present?
    results = results.by_tag(params[:tag_name])                   if params[:tag_name].present?
    results = results.by_valuator(params[:valuator_id])           if params[:valuator_id].present?
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

  def marked_as_unfeasible?
    previous_changes.has_key?("feasible") && unfeasible?
  end

  def unfeasible?
    not feasible?
  end

end
