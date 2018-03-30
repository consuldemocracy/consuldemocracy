# coding: utf-8
require 'rails_helper'

describe Article do
  let(:article) { build(:article) }

  it "is valid" do
    expect(article).to be_valid
  end
end
