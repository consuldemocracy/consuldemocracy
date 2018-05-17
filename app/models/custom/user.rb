require_dependency Rails.root.join('app', 'models', 'user').to_s

class User < ActiveRecord::Base

  GENDERS = %w(male female).freeze

  validates :firstname,
            :lastname,
            :date_of_birth,
            :postal_code,
            presence: true, if: :username_required?

  validate :postal_code_in_aude, if: :username_required?
  private def postal_code_in_aude
    errors.add(:postal_code, :not_allowed) unless valid_postal_code?
  end

  validate :age_in_allowed_range, if: :username_required?
  private def age_in_allowed_range
    errors.add(:date_of_birth, :not_allowed) unless valid_age?
  end

  private def set_default_username
    self.username = [lastname, firstname].join(" ")
  end
  before_validation :set_default_username, if: -> { username.blank? && !erased? }

  # Instance methods ==================================================

  def erase(erase_reason = nil)
    update(
      erased_at: Time.current,
      erase_reason: erase_reason,
      username: nil,
      email: nil,
      unconfirmed_email: nil,
      phone_number: nil,
      encrypted_password: "",
      confirmation_token: nil,
      reset_password_token: nil,
      email_verification_token: nil,
      confirmed_phone: nil,
      unconfirmed_phone: nil,
      firstname: nil,
      lastname: nil,
      postal_code: nil,
      date_of_birth: nil
    )
    identities.destroy_all
  end



  def self.maximum_required_age
    (Setting['max_age_to_participate'] || 25).to_i
  end

  # Omniauth --------------------------------------------------------------------------

  # appelé lors de la liaison Omniauth.
  # Remplit les champs possibles avec les données récupérées de Omniauth2.
  def fill_from_omniauth(auth)
    oauth_email           = auth['info']['email']
    oauth_email_confirmed = oauth_email.present? && (auth['info']['verified'] || auth['info']['verified_email'])

    self.identities << Identity.new(provider: auth['provider'], uid: auth['uid'])
    self.email = oauth_email if self.email.blank?
    self.oauth_email = oauth_email if self.email.blank?

    self.lastname       = auth['info']['last_name'] if self.lastname.blank?
    self.firstname      = auth['info']['first_name'] if self.firstname.blank?
    self.username       = auth['info']['name'] if self.username.blank?

    self.confirmed_at =  DateTime.current if (oauth_email_confirmed && self.confirmed_at.blank?)

  end

  # Appelé par Devise lors de l'inscription via omniauth
  def self.new_with_session(params, session)
    super.tap do |user|
      if auth = session[:omniauth]
        user.fill_from_omniauth(auth)
      end
    end
  end

  private #  ==============================

  def valid_postal_code?
    postal_code =~ /^(11)[ ]?\d{3}/ # begins with 11, followed with a space or not, and 3 digits
  end

  def valid_age?(today = Date.current)
    return if errors[:date_of_birth].any?
    not_to_young && not_to_old
  end

  def not_to_young(today = Date.current)
    Age.in_years(date_of_birth) >= User.minimum_required_age
  end

  def not_to_old(today = Date.current)
    Age.in_years(date_of_birth) < User.maximum_required_age
  end


end
