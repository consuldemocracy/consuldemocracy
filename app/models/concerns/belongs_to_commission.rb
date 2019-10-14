module BelongsToCommission
  extend ActiveSupport::Concern

  included do
    belongs_to :commission
    validate :validate_commission_can_not_be_updated_twice
  end


  def validate_commission_can_not_be_updated_twice
    return true if commission_id_was.nil?
    errors.add(:commission, I18n.t('errors.commission_can_not_be_updated_twice')) unless commission_id_was.eql?(commission_id)
  end

  class_methods do
  end

end