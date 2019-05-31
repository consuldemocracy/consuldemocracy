shared_examples "remotely_translatable" do |factory_name, path_name, path_arguments|

  let(:arguments) do
    path_arguments.map do |argument_name, path_to_value|
      [argument_name, resource.send(path_to_value)]
    end.to_h
  end
  let(:path) { send(path_name, arguments) }
  let!(:resource) { create(factory_name) }

  before do
    Setting["feature.remote_translations"] = true
  end

  after do
    Setting["feature.remote_translations"] = false
  end

  context "Button to request remote translation" do

    scenario "should not be present when current locale translation exists", :js do
      visit path

      expect(page).not_to have_button("Translate page")
    end

    scenario "should be present when current locale translation does not exists", :js do
      visit path

      select("Deutsch", from: "locale-switcher")

      expect(page).to have_button("Translate page")
    end

    scenario "should not be present when new current locale translation exists", :js do
      add_translations(resource)
      visit path
      expect(page).not_to have_button("Translate page")

      select("Deutsch", from: "locale-switcher")

      expect(page).not_to have_button("Translate page")
    end

    scenario "should not be present when there are no resources to translate", :js do
      skip("only index_path") if show_path?(path_name)
      resource.destroy
      visit path

      select("Deutsch", from: "locale-switcher")

      expect(page).not_to have_button("Translate page")
    end

    describe "with delayed job active" do
      before { Delayed::Worker.delay_jobs = true }
      after  { Delayed::Worker.delay_jobs = false }

      scenario "should not be present when an equal RemoteTranslation is enqueued", :js do
        create(:remote_translation, remote_translatable: resource, locale: :de)
        visit path

        select("Deutsch", from: "locale-switcher")

        expect(page).not_to have_button("Translate page")
        expect(page).to have_content("In a short period of time refreshing the page you will be able to see all the content in your language.")
      end
    end

    describe "should ignore missing translations on resource comments" do

      before do
        if show_path?(path_name) || !commentable?(resource)
          skip("only index_path")
        end
      end

      scenario "is not present when a resource translation exists but its comment has not tanslations", :js do
        add_translations(resource)
        create(:comment, commentable: resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select("Deutsch", from: "locale-switcher")

        expect(page).not_to have_button("Translate page")
      end

    end

    describe "should evaluate missing translations on resource comments" do

      before do
        if index_path?(path_name)
          skip("only show_path")
        end
      end

      scenario "display when exists resource translations but the comment does not have a translation", :js do
        add_translations(resource)
        create(:comment, commentable: resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select("Deutsch", from: "locale-switcher")

        expect(page).to have_button("Translate page")
      end

      scenario "not display when exists resource translations but his comment has tanslations", :js do
        add_translations(resource)
        create_comment_with_translations(resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select("Deutsch", from: "locale-switcher")

        expect(page).not_to have_button("Translate page")
      end

    end

    describe "should evaluate missing translations on featured_debates" do

      before { skip("only debates index path") if path_name != "debates_path" }

      scenario "display when exists featured_debates without tanslations", :js do
        add_translations(resource)
        create_featured_debates
        visit path
        expect(page).not_to have_button("Translate page")

        select("Deutsch", from: "locale-switcher")

        expect(page).to have_button("Translate page")
      end

    end

    describe "should evaluate missing translations on featured_proposals" do

      before { skip("only proposals index path") if path_name != "proposals_path" }

      scenario "display when exists featured_proposals without tanslations", :js do
        add_translations(resource)
        create_featured_proposals
        visit path
        expect(page).not_to have_button("Translate page")

        select("Deutsch", from: "locale-switcher")

        expect(page).to have_button("Translate page")
      end

    end

  end

  context "After click remote translations button" do

    describe "with delayed jobs" do

      before do
        Delayed::Worker.delay_jobs = true
      end

      after do
        Delayed::Worker.delay_jobs = false
      end

      scenario "the remote translation button should not be present", :js do
        visit path
        select("Deutsch", from: "locale-switcher")

        click_button "Translate page"

        expect(page).not_to have_button("Translate page")
      end

      scenario "the remote translation is pending to translate", :js do
        visit path
        select("Deutsch", from: "locale-switcher")

        expect { click_button "Translate page" }.to change { RemoteTranslation.count }.from(0).to(1)
      end

      scenario "should be present enqueued notice and informative text", :js do
        visit path
        select("Deutsch", from: "locale-switcher")

        click_button "Translate page"

        expect(page).to have_content("Translations have been correctly requested.")
        expect(page).to have_content("In a short period of time refreshing the page you will be able to see all the content in your language.")
      end

      scenario "should be present only informative text when user visit page with all content enqueued", :js do
        visit path
        select("Deutsch", from: "locale-switcher")
        click_button "Translate page"
        expect(page).to have_content("Translations have been correctly requested.")

        visit path
        select("Deutsch", from: "locale-switcher")

        expect(page).not_to have_button "Translate text"
        expect(page).not_to have_content("Translations have been correctly requested.")
        expect(page).to have_content("In a short period of time refreshing the page you will be able to see all the content in your language.")
      end

    end

    describe "without delayed jobs" do

      scenario "the remote translation button should not be present", :js do
        microsoft_translate_client_response = generate_response(resource)
        expect_any_instance_of(RemoteTranslations::Microsoft::Client).to receive(:call).and_return(microsoft_translate_client_response)
        visit path
        select("Deutsch", from: "locale-switcher")

        click_button "Translate page"

        expect(page).not_to have_button("Translate page")
      end

      scenario "the remote translation has been translated and destoyed", :js do
        microsoft_translate_client_response = generate_response(resource)
        expect_any_instance_of(RemoteTranslations::Microsoft::Client).to receive(:call).and_return(microsoft_translate_client_response)
        visit path
        select("Deutsch", from: "locale-switcher")

        click_button "Translate page"

        expect(RemoteTranslation.count).to eq(0)
        expect(resource.translations.count).to eq(2)
      end

    end

  end

end

def add_translations(resource)
  new_translation = resource.translations.first.dup
  new_translation.update(locale: :de)
  resource
end

def create_comment_with_translations(resource)
  comment = create(:comment, commentable: resource)
  add_translations(comment)
end

def index_path?(path)
  ["debates_path", "proposals_path", "root_path", "budget_investments_path"].include?(path)
end

def show_path?(path)
  !index_path?(path)
end

def commentable?(resource)
  Comment::COMMENTABLE_TYPES.include?(resource.class.to_s)
end

def generate_response(resource)
  field_text = Faker::Lorem.characters(10)
  resource.translated_attribute_names.map { |field| field_text }
end
