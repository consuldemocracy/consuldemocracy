class Admin::SearchComponent < ApplicationComponent
  attr_reader :url

  def initialize(url:)
    @url = url
  end
end
