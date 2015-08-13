class Organization < ActiveRecord::Base

  belongs_to :user

  delegate :email, :phone_number, to: :user

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
