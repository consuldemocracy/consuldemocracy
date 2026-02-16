class Officing::BallotSheets::ShowComponent < ApplicationComponent
  attr_reader :ballot_sheet

  def initialize(ballot_sheet)
    @ballot_sheet = ballot_sheet
  end
end
