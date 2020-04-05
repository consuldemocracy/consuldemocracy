class PhysicalFinalVote < ActiveRecord::Base
  belongs_to :signable, polymorphic: true

  VALID_SIGNABLES = %w(Budget::Investment)
  
  validates :booth, presence: true
  validates :total_votes, presence: true
  validates :signable_type, inclusion: {in: VALID_SIGNABLES}

  def name
    "#{signable_name} #{signable_id}"
  end

  def signable_name
    I18n.t("activerecord.models.#{signable_type.underscore}", count: 1)
  end

  def signable_found
    errors.add(:signable_id, :not_found) if errors.messages[:signable].present?
  end
end