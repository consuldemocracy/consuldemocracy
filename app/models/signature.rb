class Signature < ActiveRecord::Base
  belongs_to :signature_sheet
  belongs_to :user

  validates :document_number, presence: true
  validates :signature_sheet, presence: true

  scope :verified,   -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  delegate :signable, to: :signature_sheet

  before_validation :clean_document_number

  def verify
    if user_exists?
      assign_vote_to_user
      mark_as_verified
    elsif in_census?
      create_user
      assign_vote_to_user
      mark_as_verified
    end
  end

  def assign_vote_to_user
    set_user
    if signable.is_a? Budget::Investment
      signable.vote_by(voter: user, vote: 'yes') if [nil, :no_selecting_allowed].include?(signable.reason_for_not_being_selectable_by(user))
    else
      signable.register_vote(user, "yes")
    end
    assign_signature_to_vote
  end

  def assign_signature_to_vote
    vote = Vote.where(votable: signable, voter: user).first
    vote.update(signature: self) if vote
  end

  def user_exists?
    User.where(document_number: document_number).any?
  end

  def create_user
    user_params = {
      document_number: document_number,
      created_from_signature: true,
      verified_at: Time.current,
      erased_at: Time.current,
      password: random_password,
      terms_of_service: '1',
      email: nil,
      date_of_birth: @census_api_response.date_of_birth,
      gender: @census_api_response.gender,
      geozone: Geozone.where(census_code: @census_api_response.district_code).first
    }
    User.create!(user_params)
  end

  def clean_document_number
    return if document_number.blank?
    self.document_number = document_number.gsub(/[^a-z0-9]+/i, "").upcase
  end

  def random_password
    (0...20).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def in_census?
    document_types.detect do |document_type|
      response = CensusCaller.new.call(Tenant.find_by(subdomain: Apartment::Tenant.current), document_type, document_number)
      if response.valid?
        @census_api_response = response
        true
      else
        false
      end
    end

    @census_api_response.present?
  end

  def set_user
    user = User.where(document_number: document_number).first
    update(user: user)
  end

  def mark_as_verified
    update(verified: true)
  end

  def document_types
    %w(1 2 3 4)
  end

end
