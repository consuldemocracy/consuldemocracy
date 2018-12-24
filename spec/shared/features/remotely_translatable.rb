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

  context "Remote translations button" do

    scenario "should not be present when current locale translation exists", :js do
      visit path

      expect(page).not_to have_button("Translate page")
    end

    scenario "should be present when current locale translation does not exists", :js do
      visit path

      select('Español', from: 'locale-switcher')

      expect(page).to have_button("Traducir página")
    end

    scenario "should not be present when new current locale translation exists", :js do
      add_translations(resource)
      visit path
      expect(page).not_to have_button("Translate page")

      select('Español', from: 'locale-switcher')

      expect(page).not_to have_button("Traducir página")
    end

    scenario "should not be present when there is no resources to translate", :js do
      skip("only index_path") if show_path?(path_name)
      resource.destroy
      visit path

      select('Español', from: 'locale-switcher')

      expect(page).not_to have_button("Traducir página")
    end

    scenario "should be present when exist an equal RemoteTranslation is enqueued", :js do
      Delayed::Worker.delay_jobs = true

      create(:remote_translation, remote_translatable: resource, locale: :es)
      visit path

      select('Español', from: 'locale-switcher')

      expect(page).to have_button("Traducir página")

      Delayed::Worker.delay_jobs = false
    end

    describe "should ignore missing translations on resource comments" do

      before do
        if show_path?(path_name) || !commentable?(resource)
          skip("only index_path")
        end
      end

      scenario "is not present when exists resource translations but his comment has not tanslations", :js do
        add_translations(resource)
        create(:comment, commentable: resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).not_to have_button("Traducir página")
      end

    end

    describe "should evaluate missing translations on resource comments" do

      before do
        if index_path?(path_name)
          skip("only show_path")
        end
      end

      scenario "display when exists resource translations but his comment has not tanslations", :js do
        add_translations(resource)
        create(:comment, commentable: resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).to have_button("Traducir página")
      end

      scenario "not display when exists resource translations but his comment has tanslations", :js do
        add_translations(resource)
        create_comment_with_translations(resource)
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).not_to have_button("Traducir página")
      end

    end

    describe "should evaluate missing translations on featured_debates" do

      before { skip("only debates index path") if path_name != "debates_path" }

      scenario "display when exists featured_debates without tanslations", :js do
        add_translations(resource)
        create_featured_debates
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).to have_button("Traducir página")
      end

    end

    describe "should evaluate missing translations on featured_proposals" do

      before { skip("only proposals index path") if path_name != "proposals_path" }

      scenario "display when exists featured_proposals without tanslations", :js do
        add_translations(resource)
        create_featured_proposals
        visit path
        expect(page).not_to have_button("Translate page")

        select('Español', from: 'locale-switcher')

        expect(page).to have_button("Traducir página")
      end

    end

  end

  context "After request translations" do

    describe "with delayed jobs" do

      before do
        Delayed::Worker.delay_jobs = true
      end

      after do
        Delayed::Worker.delay_jobs = false
      end

      scenario "should be present remote translations button", :js do
        visit path
        select('Español', from: 'locale-switcher')

        click_button "Traducir página"

        expect(page).to have_button("Traducir página")
      end

      scenario "should be present enqueued notice", :js do
        visit path
        select('Español', from: 'locale-switcher')

        click_button "Traducir página"

        expect(page).to have_content("Las traducciones solicitadas estan pendientes de traducir. En un breve peridodo de tiempo refrescando la página podrá ver las traducciones.")
      end

    end

  end

end

def add_translations(resource)
  new_translation = resource.translations.first.dup
  new_translation.update(locale: :es)
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
