class Signature < ActiveRecord::Base
  belongs_to :signature_sheet
  belongs_to :user

  validates :document_number, presence: true
  validates :signature_sheet, presence: true

  scope :verified,   -> { where(verified: true) }
  scope :unverified, -> { where(verified: false) }

  before_save :verify

  def verify
    if verified?
      assign_vote
      verified = true
    end
  end

  def verified?
    user_exists? || in_census?
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
    signable.register_vote(user, "yes", "signature")
  end

  def user_exists?
    user = User.where(document_number: document_number).exists?
  end

  def create_user
    user = User.where(document_number: document_number, erased_at: Time.now).create
  end

  def in_census?
    document_types.any? do |document_type|
      CensusApi.new.call(document_type, document_number).valid?
    end
  end

  def signable
    signature_sheet.signable
  end

  def document_types
    %w(1 2 3 4)
  end

end