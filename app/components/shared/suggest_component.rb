class Shared::SuggestComponent < ApplicationComponent
  attr_reader :resources, :search_terms, :resource_path_method
  delegate :resource_name, :resource_model, :namespaced_budget_investment_path, to: :helpers

  def initialize(resources, search_terms:, resource_path_method: nil)
    @resources = resources
    @search_terms = search_terms
    @resource_path_method = resource_path_method
  end

  def render?
    search_terms && resources.any?
  end

  private

    def limit
      5
    end
end
