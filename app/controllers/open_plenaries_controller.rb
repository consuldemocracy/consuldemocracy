class OpenPlenariesController < ApplicationController

  skip_authorization_check

  def results
    @questions = Debate.open_plenary_winners
    @proposals = Proposal.open_plenary_winners
  end

end