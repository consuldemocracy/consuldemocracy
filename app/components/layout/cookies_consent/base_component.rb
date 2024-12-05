class Layout::CookiesConsent::BaseComponent < ApplicationComponent
  delegate :current_user, to: :helpers

  def render?
    feature?(:cookies_consent) && (public_setup? || testing_setup?)
  end

  private

    def version_name
      Setting["cookies_consent.version_name"]
    end

    def public_setup?
      !feature?("cookies_consent.admin_test_mode")
    end

    def testing_setup?
      current_user&.administrator? && !public_setup?
    end
end
