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

  def username_required?
    return false if origin_participacion
    !organization? && !erased?
  end

  def hasNationalId?
    return document_number.present?
  end

  # Queremos evitar que podamos autenticarnos como usuarios de participacion
  # externos... que la clave es una de mentira...
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    where(conditions.to_hash).find_by(["lower(email) = ? AND origin_participacion is NULL",login.downcase]) ||
    where(conditions.to_hash).find_by(["username = ? AND origin_participacion is NULL", login])
  end
end
