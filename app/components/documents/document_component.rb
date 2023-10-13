class Documents::DocumentComponent < ApplicationComponent
  attr_reader :document
  delegate :can?, to: :helpers

  def initialize(document)
    @document = document
  end
end
