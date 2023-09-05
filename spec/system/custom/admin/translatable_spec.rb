require "rails_helper"

describe "Admin edit translatable records", :admin do
  before do
    translatable.main_link_url = "https://consuldemocracy.org" if translatable.is_a?(Budget::Phase)
    translatable.update!(attributes)
  end

  let(:fields) { translatable.translated_attribute_names }

  let(:attributes) do
    fields.product(%i[en es]).to_h do |field, locale|
      [:"#{field}_#{locale}", text_for(field, locale)]
    end
  end

  context "Update a translation" do
    context "Change value of a translated field to blank" do
      let(:translatable) { create(:poll, :future) }
      let(:path) { edit_admin_poll_path(translatable) }

      scenario "Updates the field to a blank value" do
        visit path

        expect(page).to have_ckeditor "Summary", with: "Summary in English"

        fill_in_ckeditor "Summary", with: " "
        click_button "Update poll"

        visit path

        expect(page).to have_ckeditor "Summary", with: ""
      end
    end
  end
end
