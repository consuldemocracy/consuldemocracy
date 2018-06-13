# coding: utf-8
require 'rails_helper'

describe Proposal do
  let(:user) { create(:user, document_number: nil) }
  let(:proposal) { build(:proposal, author: user, responsible_name: nil) }

  before do
    Setting["feature.user.skip_verification"] = 'true'
  end

  after do
    Setting["feature.user.skip_verification"] = 'false'
  end

  it "is valid with user without verification" do
    expect(proposal).to be_valid
  end

end
