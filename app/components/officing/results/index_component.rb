class Officing::Results::IndexComponent < ApplicationComponent
  attr_reader :poll, :partial_results, :booth_assignment, :recounts

  def initialize(poll, partial_results, booth_assignment, recounts)
    @poll = poll
    @partial_results = partial_results
    @booth_assignment = booth_assignment
    @recounts = recounts
  end
end
