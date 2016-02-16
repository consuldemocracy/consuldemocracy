class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable

  apply_simple_captcha

  RESOLUTIONS = ["accepted", "rejected"]

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone

  validates :title, presence: true
  validates :author, presence: true
  validates :description, presence: true

  validates :title, length: { in: 4..SpendingProposal.title_max_length }
  validates :description, length: { maximum: SpendingProposal.description_max_length }
  validates :resolution,  inclusion: { in: RESOLUTIONS, allow_nil: true }
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  scope :accepted, -> { where(resolution: "accepted") }
  scope :rejected, -> { where(resolution: "rejected") }
  scope :unresolved, -> { where(resolution: nil) }

  def accept
    update_attribute(:resolution, "accepted")
  end

  def reject
    update_attribute(:resolution, "rejected")
  end

  def accepted?
    resolution == "accepted"
  end

  def rejected?
    resolution == "rejected"
  end

  def unresolved?
    resolution.blank?
  end

  def legality
    case legal
    when true
      "legal"
    when false
      "no_legal"
    else
      "undefined"
    end
  end

  def feasibility
    case feasible
    when true
      "feasible"
    when false
      "no_feasible"
    else
      "undefined"
    end
  end
end
