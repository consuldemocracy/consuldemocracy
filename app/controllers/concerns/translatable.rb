module Translatable
  extend ActiveSupport::Concern

  included do
    before_action :set_translation_locale
  end

  private

    def translation_params
      Budget::Investment::Milestone.globalize_attribute_names.
      select { |k, v| params[:budget_investment_milestone].include?(k.to_sym) && params[:budget_investment_milestone][k].present? }
    end

    def set_translation_locale
      Globalize.locale = I18n.locale
    end

end