class Admin::Legislation::BaseController < Admin::BaseController
  include FeatureFlags

  feature_flag :legislation
end
