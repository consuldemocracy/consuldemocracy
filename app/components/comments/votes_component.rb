class Comments::VotesComponent < ApplicationComponent
  attr_reader :comment
  delegate :can?, to: :helpers

  def initialize(comment)
    @comment = comment
  end
end
