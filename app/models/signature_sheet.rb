class SignatureSheet < ApplicationRecord
  belongs_to :signable, polymorphic: true
  belongs_to :author, class_name: "User", foreign_key: "author_id"

  VALID_SIGNABLES = %w(Proposal Budget::Investment)

  has_many :signatures

  validates :author, presence: true
  validates :signable_type, inclusion: {in: VALID_SIGNABLES}
  validates :required_fields_to_verify, presence: true
  validates :signable, presence: true
  validate  :signable_found

  def name
    "#{signable_name} #{signable_id}"
  end

  def signable_name
    I18n.t("activerecord.models.#{signable_type.underscore}", count: 1)
  end

  def verify_signatures
    parsed_required_fields_to_verify_groups.each do |required_fields_to_verify|
      document_number = required_fields_to_verify[0]
      date_of_birth = required_fields_to_verify[1]
      postal_code = required_fields_to_verify[2]

      signature = signatures.where(document_number: document_number,
                                   date_of_birth: date_of_birth,
                                   postal_code: postal_code).first_or_create
      signature.verify
    end
    update(processed: true)
  end

  def parsed_required_fields_to_verify_groups
    required_fields_to_verify.split(/[;]/).collect {|d| d.gsub(/\s+/, "") }.map { |group| group.split(/[,]/)}
  end

  def signable_found
    errors.add(:signable_id, :not_found) if errors.messages[:signable].present?
  end
end
