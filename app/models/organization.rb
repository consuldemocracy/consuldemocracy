class Organization < ActiveRecord::Base

  belongs_to :user

  validates :name, presence: true

  delegate :email, :phone_number, to: :user

  scope :pending, -> { where(verified_at: nil, rejected_at: nil) }
  scope :verified, -> { where("verified_at is not null and (rejected_at is null or rejected_at < verified_at)") }
  scope :rejected, -> { where("rejected_at is not null and (verified_at is null or verified_at < rejected_at)") }

  def verify
    update(verified_at: Time.now)
  end

  def reject
    update(rejected_at: Time.now)
  end

  def verified?
    verified_at.present? &&
      (rejected_at.blank? || rejected_at < verified_at)
  end

  def rejected?
    rejected_at.present? &&
      (verified_at.blank? || verified_at < rejected_at)
  end

end
