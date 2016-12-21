require 'rails_helper'

RSpec.describe Legislation::Question, type: :model do
  let(:legislation_question) { build(:legislation_question) }

  it "should be valid" do
    expect(legislation_question).to be_valid
  end
end
