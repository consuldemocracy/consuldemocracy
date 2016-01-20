module FeatureFlagsHelper
  def feature?(name)
    !!Setting["feature.#{name}"]
  end
end
