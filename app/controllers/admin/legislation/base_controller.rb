class Admin::Legislation::BaseController < Admin::BaseController
  include FeatureFlags

  feature_flag :legislation

  helper_method :namespace

  private

    def namespace
      "admin"
    end

end
