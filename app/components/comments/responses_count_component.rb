class Comments::ResponsesCountComponent < ApplicationComponent
  attr_reader :count

  def initialize(count)
    @count = count
  end
end
