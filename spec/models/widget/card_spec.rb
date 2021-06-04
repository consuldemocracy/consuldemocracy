require "rails_helper"

describe Widget::Card do
  let(:card) { build(:widget_card) }

  it_behaves_like "globalizable", :widget_card

  context "validations" do
    it "is valid" do
      expect(card).to be_valid
    end

    it "is not valid without a title" do
      expect(build(:widget_card, title: "")).not_to be_valid
    end
  end

  describe "#header" do
    it "returns header cards" do
      header = create(:widget_card, header: true)

      expect(Widget::Card.header).to eq([header])
    end

    it "does not return regular cards" do
      create(:widget_card, header: false)

      expect(Widget::Card.header).to be_empty
    end
  end

  describe "#body" do
    it "returns cards for the homepage body" do
      header = create(:widget_card, header: true)
      card1 = create(:widget_card, header: false)
      card2 = create(:widget_card, header: false)
      page_card = create(:widget_card, header: false, cardable: create(:site_customization_page))

      expect(Widget::Card.body).to match_array [card1, card2]
      expect(Widget::Card.body).not_to include(header)
      expect(Widget::Card.body).not_to include(page_card)
    end
  end
end
