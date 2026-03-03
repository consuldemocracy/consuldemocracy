class MachineLearningJob < ApplicationRecord
  belongs_to :user, optional: false

  def active?
    started?
  end

  def started?
    started_at.present? && finished_at.blank? && error.blank?
  end

  def finished?
    finished_at.present? && error.blank?
  end

  def errored?
    error.present?
  end

  def duration
    return 0 unless started_at && finished_at

    (finished_at - started_at).to_i
  end

  def running_for_too_long?
    started? && started_at < 1.day.ago
  end
end
