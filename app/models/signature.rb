class Signature < ActiveRecord::Base
  belongs_to :signature_sheet
  belongs_to :user

  validates :document_number, presence: true
  validates :signature_sheet, presence: true

  scope :verified,   -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  delegate :signable, to: :signature_sheet

  before_validation :clean_document_number

  def verified?
    user_exists? || in_census?
  end

  def verify
    if verified?
      assign_vote
      mark_as_verified
    end
  end

  def assign_vote
    if user_exists?
      assign_vote_to_user
    else
      create_user
      assign_vote_to_user
    end
  end

  def assign_vote_to_user
    set_user
    signable.register_vote(user, "yes")
    assign_signature_to_vote
  end

  def assign_signature_to_vote
    vote = Vote.where(votable: signable, voter: user).first
    vote.update(signature: self)
  end

  def user_exists?
    User.where(document_number: document_number).any?
  end

  def create_user
    user_params = {
      document_number: document_number,
      created_from_signature: true,
      verified_at: Time.now,
      erased_at: Time.now,
      password: random_password,
      terms_of_service: '1',
      email: nil
    }
    User.create!(user_params)
  end

  def clean_document_number
    return if self.document_number.blank?
    self.document_number = self.document_number.gsub(/[^a-z0-9]+/i, "").upcase
  end

  def random_password
    (0...20).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def in_census?
    response = document_types.detect do |document_type|
      CensusApi.new.call(document_type, document_number).valid?
    end
    response.present?
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