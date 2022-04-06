require "rails_helper"

describe Widget::Card do
  let(:card) { build(:widget_card) }

  it_behaves_like "globalizable", :widget_card

  context "validations" do
    it "is valid" do
      expect(card).to be_valid
    end

    it "is valid with a header" do
      expect(build(:widget_card, :header)).to be_valid
    end

    it "is not valid without a title" do
      expect(build(:widget_card, title: "")).not_to be_valid
    end

    context "regular cards" do
      it "is not valid without a link_url" do
        card = build(:widget_card, header: false, link_url: nil)

        expect(card).not_to be_valid
      end
    end

    context "header cards" do
      it "is valid with no link_url and no link_text" do
        header = build(:widget_card, :header, link_text: nil, link_url: nil)

        expect(header).to be_valid
      end

      it "is not valid with link_text and no link_url" do
        header = build(:widget_card, :header, link_text: "link text", link_url: nil)

        expect(header).not_to be_valid
        expect(header.errors.count).to be 1
        expect(header.errors[:link_url].count).to be 1
        expect(header.errors[:link_url].first).to eq "can't be blank"
      end

      it "is valid if link_text and link_url are both provided" do
        header = build(:widget_card, :header, link_text: "Text link",
                                              link_url: "https://consulproject.org")

        expect(header).to be_valid
      end
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
