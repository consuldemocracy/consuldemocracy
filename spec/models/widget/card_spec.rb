require "rails_helper"

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
      card1 = create(:widget_card, header: false)
      card2 = create(:widget_card, header: false)
      page_card = create(:widget_card, header: false, page: create(:site_customization_page))

      expect(Widget::Card.body).to include(card1)
      expect(Widget::Card.body).to include(card2)
      expect(Widget::Card.body).not_to include(header)
      expect(Widget::Card.body).not_to include(page_card)
    end
  end

  describe "#custom page" do

    it "return cards for the custom pages" do
      header = create(:widget_card, header: true)
      card = create(:widget_card, header: false)
      card1 = create(:widget_card, header: false, title: "Card 1", site_customization_page_id: 1)
      card2 = create(:widget_card, header: false, title: "Card 2", site_customization_page_id: 1)
      card3 = create(:widget_card, header: false, title: "Card 3", site_customization_page_id: 1)

      expect(Widget::Card.page(1)).to eq([card1, card2, card3])
    end
  end

end