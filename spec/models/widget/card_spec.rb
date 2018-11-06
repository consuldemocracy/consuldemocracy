require 'rails_helper'

describe Widget::Card do

  let(:card) { build(:widget_card) }

  context "validations" do

    it "is valid" do
      expect(card).to be_valid
    end

  end

  describe "#header" do

    it "returns the header card" do
      header = create(:widget_card, header: true)
      card = create(:widget_card, header: false)

      expect(Widget::Card.header).to eq([header])
    end
  end

  describe "#body" do

    it "returns cards for the homepage body" do
      header = create(:widget_card, header: true)
      card1 = create(:widget_card, header: false, title: "Card 1")
      card2 = create(:widget_card, header: false, title: "Card 2")
      card3 = create(:widget_card, header: false, title: "Card 3")

      expect(Widget::Card.body).to eq([card1, card2, card3])
    end
  end

end