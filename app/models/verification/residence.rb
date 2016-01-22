class Verification::Residence
  include ActiveModel::Model
  include ActiveModel::Dates

  attr_accessor :user, :document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service

  validates_presence_of :document_number
  validates_presence_of :document_type
  validates_presence_of :date_of_birth
  validates_presence_of :postal_code
  validates :terms_of_service, acceptance: { allow_nil: false }

  validates :postal_code, length: { is: 5 }

  validate :allowed_age
  validate :document_number_uniqueness
  validate :validate_postal_code
  validate :residency

  def initialize(attrs={})
    self.date_of_birth = parse_date('date_of_birth', attrs)
    attrs = remove_date('date_of_birth', attrs)
    super
    clean_document_number
  end

  def save
    return false unless valid?
    user.update(document_number:       document_number,
                document_type:         document_type,
                residence_verified_at: Time.now)
  end

  def allowed_age
    return if errors[:date_of_birth].any?
    errors.add(:date_of_birth, I18n.t('verification.residence.new.error_not_allowed_age')) unless self.date_of_birth <= 16.years.ago
  end

  def document_number_uniqueness
    errors.add(:document_number, I18n.t('errors.messages.taken')) if User.where(document_number: document_number).any?
  end

  def validate_postal_code
    errors.add(:postal_code, I18n.t('verification.residence.new.error_not_allowed_postal_code')) unless valid_postal_code?
  end

  def residency
    return if errors.any?

    unless residency_valid?
      errors.add(:residency, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  def store_failed_attempt
    FailedCensusCall.create({
      user: user,
      document_number: document_number,
      document_type:   document_type,
      date_of_birth:   date_of_birth,
      postal_code:     postal_code
    })
  end

  private

    def residency_valid?
      Census.new(
        document_type: document_type,
        document_number: document_number,
        postal_code: postal_code,
        date_of_birth: date_of_birth
      ).valid?
    end

    def clean_document_number
      self.document_number = self.document_number.gsub(/[^a-z0-9]+/i, "").upcase unless self.document_number.blank?
    end

    def valid_postal_code?
      postal_code =~ /^080/
    end

end
