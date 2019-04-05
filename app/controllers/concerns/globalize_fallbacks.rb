module GlobalizeFallbacks
  extend ActiveSupport::Concern

  included do
    before_action :initialize_globalize_fallbacks
  end

  private

    def initialize_globalize_fallbacks
      Globalize.set_fallbacks_to_all_available_locales
    end
end
