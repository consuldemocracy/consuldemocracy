class Admin::Poll::BaseController < Admin::BaseController
  include FeatureFlags

  feature_flag :polls

  helper_method :namespace

  private

    def namespace
      "admin"
    end
end
