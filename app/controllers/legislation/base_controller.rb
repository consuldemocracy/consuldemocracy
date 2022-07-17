class Legislation::BaseController < ApplicationController
  include FeatureFlags

  feature_flag :legislation
end
