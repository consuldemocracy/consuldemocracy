class Shared::BasicAuthorInfoComponent < ApplicationComponent
  attr_reader :author, :show_organization
  alias_method :show_organization?, :show_organization

  def initialize(author, show_organization: true)
    @author = author
    @show_organization = show_organization
  end
end
