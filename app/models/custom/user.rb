require_dependency Rails.root.join("app", "models", "user").to_s

class User < ApplicationRecord
  attr_accessor :skip_email_validation

  def email_required?
    return false if skip_email_validation

    !erased? && unverified?
  end
end
