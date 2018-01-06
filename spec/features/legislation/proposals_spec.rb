require 'rails_helper'

describe 'Legislation Proposals' do

  context "Concerns" do
    it_behaves_like 'notifiable in-app', Legislation::Proposal
  end

end
