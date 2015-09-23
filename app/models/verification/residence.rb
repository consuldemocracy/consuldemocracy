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
  validate :residence_in_madrid

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

  def document_number_uniqueness
    errors.add(:document_number, I18n.t('errors.messages.taken')) if User.where(document_number: document_number).any?
  end

  def residence_in_madrid
    return if errors.any?
    self.date_of_birth = date_to_string(date_of_birth)

    residency = CensusApi.new(self)

    unless residency.valid?
      errors.add(:residence_in_madrid, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
    self.date_of_birth = string_to_date(date_of_birth)
  end

  def allowed_age
    return if errors[:date_of_birth].any?
    errors.add(:date_of_birth, I18n.t('verification.residence.new.error_not_allowed_age')) unless self.date_of_birth <= 16.years.ago
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

    def clean_document_number
      self.document_number = self.document_number.gsub(/[^a-z0-9]+/i, "").upcase unless self.document_number.blank?
    end

    def self.valid_postal_codes
      %w(28001 28002 28003 28004 28005 28006 28007 28008 28009 28010 28011 28012 28013 28014 28015 28016 28017 28018 28019 28020 28021 28022 28023 28024 28025 28026 28027 28028 28029 28030 28031 28032 28033 28034 28035 28036 28037 28038 28039 28040 28041 28042 28043 28044 28045 28046 28047 28048 28049 28050 28051 28052 28053 28054 28055 28790)
    end

end
