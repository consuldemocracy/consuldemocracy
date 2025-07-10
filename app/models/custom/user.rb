require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord
  has_one :consultant
  has_one :signature_sheet_officer

  scope :consultants, -> { joins(:consultant) }
  scope :signature_sheet_officers, -> { joins(:signature_sheet_officer) }

  attr_accessor :skip_email_validation

  def email_required?
    return false if skip_email_validation

    !erased? && unverified?
  end

  def consultant?
    consultant.present?
  end

  def signature_sheet_officer?
    signature_sheet_officer.present?
  end
end
