module Translatable
  extend ActiveSupport::Concern

  included do
    before_action :set_translation_locale
    before_action :delete_translations, only: [:update]
  end

  private

    def translation_params
      Budget::Investment::Milestone.globalize_attribute_names.
      select { |k, v| params[:budget_investment_milestone].include?(k.to_sym) && params[:budget_investment_milestone][k].present? }
    end

    def set_translation_locale
      Globalize.locale = I18n.locale
    end

    def delete_translations
      locales = Budget::Investment::Milestone.globalize_locales.
      select { |k, v| params[:delete_translations].include?(k.to_sym) && params[:delete_translations][k] == "1" }
      milestone = Budget::Investment::Milestone.find(params[:id])
      locales.each do |l|
        Globalize.with_locale(l) do
          milestone.translation.destroy
        end
      end
    end

end
