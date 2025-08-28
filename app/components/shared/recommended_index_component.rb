class Shared::RecommendedIndexComponent < ApplicationComponent
  attr_reader :recommendations, :namespace
  use_helpers :current_path_with_query_params

  def initialize(recommendations, namespace:)
    @recommendations = recommendations
    @namespace = namespace
  end

  def render?
    feature?("user.recommendations") && recommendations.present?
  end

  private

    def disable_recommendations_path
      if namespace == "debates"
        recommendations_disable_debates_path
      else
        recommendations_disable_proposals_path
      end
    end
end
