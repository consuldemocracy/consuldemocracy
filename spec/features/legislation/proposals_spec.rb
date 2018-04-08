require 'rails_helper'

feature 'Legislation Proposals' do

  context "Concerns" do
    it_behaves_like 'notifiable in-app', Legislation::Proposal
  end

end
