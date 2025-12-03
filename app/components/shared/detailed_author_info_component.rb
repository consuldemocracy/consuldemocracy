class Shared::DetailedAuthorInfoComponent < ApplicationComponent
  attr_reader :author

  def initialize(author)
    @author = author
  end
end
