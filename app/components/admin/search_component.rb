class Admin::SearchComponent < ApplicationComponent
  attr_reader :url, :label

  def initialize(url:, label:)
    @url = url
    @label = label
  end

  private

    def search_terms
      params[:search]
    end
end
