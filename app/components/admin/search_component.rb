class Admin::SearchComponent < ApplicationComponent
  attr_reader :url

  def initialize(url:)
    @url = url
  end

  private

    def search_terms
      params[:search]
    end

    def label
      t("admin.shared.user_search.placeholder")
    end
end
