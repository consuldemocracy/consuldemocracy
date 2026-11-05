module Api::Base
  extend ActiveSupport::Concern

  included do
    skip_forgery_protection
    respond_to :json
  end

  private

    def detect_spam(...)
    end
end
