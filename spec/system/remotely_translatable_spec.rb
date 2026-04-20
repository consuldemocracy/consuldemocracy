require "rails_helper"

describe "Remotely translatable" do
  factories = [
    :budget_investment,
    :debate,
    :legislation_process,
    :proposal
  ]

  let(:factory) { factories.sample }
  let!(:resource) { create(factory) }
  let(:provider) { [RemoteTranslations::Llm, RemoteTranslations::Microsoft].sample }
  let(:client) { provider::Client }
  let(:available_locales) { provider::AvailableLocales }
  let(:path) do
    paths = []
    paths = [show_path, index_path] if factory != :legislation_process
    paths << root_path if factory != :budget_investment
    paths.sample
  end
  let(:path_in_spanish) { "#{path}?locale=es" }
  let(:show_path) { polymorphic_path(resource) }
  let(:index_path) do
    if factory == :budget_investment
      budget_investments_path(resource.budget)
    else
      polymorphic_path(factory.to_s.pluralize.to_sym)
    end
  end

  before do
    allow(available_locales).to receive(:locales).and_return(%w[de en es fr pt zh-Hans])
    allow(RemoteTranslations::Caller).to receive_messages(translation_provider: provider,
                                                          llm?: provider == RemoteTranslations::Llm)
    if provider == RemoteTranslations::Llm
      Setting["llm.provider"] = "OpenAI"
      Setting["llm.model"] = "gpt-4o"
      Setting["llm.use_llm_for_translations"] = true
      stub_secrets(llm: { openai_api_key: "1234" })
    else
      Setting["llm.provider"] = Setting["llm.model"] = Setting["llm.use_llm_for_translations"] = nil
      Setting["feature.remote_translations"] = true
      stub_secrets(microsoft_api_key: "123")
    end
  end

  context "Button to request remote translation" do
    scenario "should not be present when current locale translation exists" do
      visit path

      expect(page).not_to have_button "Translate page"
    end

    scenario "should be present when current locale translation does not exists" do
      visit path_in_spanish

      expect(page).to have_button "Traducir página"
    end

    scenario "should not be present when new current locale translation exists" do
      add_translations(resource, :es)
      visit path

      expect(page).not_to have_button "Translate page"

      select "Español", from: "Language:"

      expect(page).to have_select "Idioma:"
      expect(page).not_to have_button "Traducir página"
    end

    context "on index path" do
      let(:path) { index_path }
      let(:factory) { (factories - [:legislation_process]).sample }

      scenario "should not be present when there are no resources to translate" do
        resource.destroy!
        visit path_in_spanish

        expect(page).not_to have_button "Traducir página"
      end

      describe "should ignore missing translations on resource comments" do
        scenario "is not present when a resource translation exists but its comment has not translations" do
          add_translations(resource, :es)
          create(:comment, commentable: resource)

          visit path

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_select "Idioma:"
          expect(page).not_to have_button "Traducir página"
        end
      end

      describe "should evaluate missing translations on featured_debates" do
        let(:factory) { :debate }

        scenario "display when exists featured_debates without translations" do
          add_translations(resource, :es)
          create_featured_debates

          visit path

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_button "Traducir página"
        end
      end

      describe "should evaluate missing translations on featured_proposals" do
        let(:factory) { :proposal }

        scenario "display when exists featured_proposals without translations" do
          add_translations(resource, :es)
          create_featured_proposals

          visit path

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_button "Traducir página"
        end
      end
    end

    describe "with delayed job active", :delay_jobs do
      scenario "should not be present when an equal RemoteTranslation is enqueued" do
        create(:remote_translation, remote_translatable: resource, locale: :es)
        visit path_in_spanish

        expect(page).to have_content "Por favor, espera 5 segundos y actualiza la página " \
                                     "para que se muestre el contenido traducido."
        expect(page).not_to have_button "Traducir página"
      end
    end

    context "on show path" do
      let(:path) { show_path }
      let(:factory) { (factories - [:legislation_process]).sample }

      describe "should evaluate missing translations on resource comments" do
        scenario "display when exists resource translations but the comment does not have a translation" do
          add_translations(resource, :es)
          create(:comment, commentable: resource)
          visit path

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_button "Traducir página"
        end

        scenario "not display when exists resource translations but his comment has translations" do
          add_translations(resource, :es)
          create_comment_with_translations(resource, :es)
          visit path

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_select "Idioma:"
          expect(page).not_to have_button "Traducir página"
        end
      end
    end
  end

  context "After click remote translations button" do
    describe "with delayed jobs", :delay_jobs do
      scenario "shows informative text when content is enqueued" do
        visit path_in_spanish

        click_button "Traducir página"

        expect(page).not_to have_button "Traducir página"
        expect(page).to have_content "Se han solicitado correctamente las traducciones."
        expect(page).to have_content "Por favor, espera 5 segundos y actualiza la página " \
                                     "para que se muestre el contenido traducido."

        refresh

        expect(page).not_to have_content "Se han solicitado correctamente las traducciones."
        expect(page).not_to have_button "Traducir página"
        expect(page).to have_content "Por favor, espera 5 segundos y actualiza la página " \
                                     "para que se muestre el contenido traducido."
      end
    end

    describe "without delayed jobs" do
      scenario "content is immediately translated" do
        response = generate_response(resource)
        expect_any_instance_of(client).to receive(:call).and_return(response)
        visit path_in_spanish

        expect(page).not_to have_content response.first

        click_button "Traducir página"

        expect(page).not_to have_button "Traducir página"
        expect(page).to have_content response.first
      end

      scenario "request a translation of an already translated text" do
        response = generate_response(resource)
        expect_any_instance_of(client).to receive(:call).and_return(response)

        using_session(:one) do
          visit path_in_spanish

          expect(page).to have_button "Traducir página"
        end

        using_session(:two) do
          visit path_in_spanish
          click_button "Traducir página"

          expect(page).to have_content "Se han solicitado correctamente las traducciones"
        end

        using_session(:one) do
          click_button "Traducir página"

          expect(page).not_to have_button "Traducir página"
        end
      end
    end
  end

  def add_translations(resource, locale)
    new_translation = resource.translations.first.dup
    new_translation.update!(locale: locale)
    resource
  end

  def create_comment_with_translations(resource, locale)
    comment = create(:comment, commentable: resource)
    add_translations(comment, locale)
  end

  def generate_response(resource)
    field_text = Faker::Lorem.characters(number: 10)
    resource.translated_attribute_names.map { field_text }
  end
end
