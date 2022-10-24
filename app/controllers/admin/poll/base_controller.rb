class Admin::Poll::BaseController < Admin::BaseController
  include FeatureFlags

  feature_flag :polls
end
