require "rails_helper"

describe AUE::Goals::IndexComponent do
  let!(:goals) { AUE::Goal.all }
  let!(:component) { AUE::Goals::IndexComponent.new(goals, header: nil) }

  before do
    Setting["feature.aue"] = true
  end

  describe "header" do
    it "renders a custom header" do
      aue_web_section = WebSection.find_by!(name: "aue")
      header = create(:widget_card, cardable: aue_web_section)
      component = AUE::Goals::IndexComponent.new(goals, header: header)

      render_inline component

      expect(page).to have_content header.title
      expect(page).not_to have_css "h1", exact_text: "Agenda Urbana Española"
    end
  end
end
