require "rails_helper"
require "sessions_helper"

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
  let(:collection_symbol) { factory.to_s.pluralize.to_sym }
  let(:path) do
    paths = []
    paths = [:show_path, :index_path] if factory != :legislation_process
    paths << :home_path if factory != :budget_investment
    paths.sample
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
      Setting["feature.remote_translations"] = true
      stub_secrets(microsoft_api_key: "123")
    end
  end

  context "Button to request remote translation" do
    scenario "should not be present when current locale translation exists" do
      visit send(path)

      expect(page).not_to have_button "Translate page"
    end

    scenario "should be present when current locale translation does not exists" do
      visit send(path, locale: :es)

      expect(page).to have_button "Traducir página"
    end

    scenario "should not be present when new current locale translation exists" do
      add_translations(resource, :es)
      visit send(path)

      expect(page).not_to have_button "Traducir página"

      select "Español", from: "Language:"

      expect(page).to have_select "Idioma:"
      expect(page).not_to have_button "Traducir página"
    end

    context "on index path" do
      let(:path) { :index_path }
      let(:factory) { (factories - [:legislation_process]).sample }

      scenario "should not be present when there are no resources to translate" do
        resource.destroy!
        visit send(path, locale: :es)

        expect(page).not_to have_button "Traducir página"
      end

      describe "should ignore missing translations on resource comments" do
        scenario "is not present when a resource translation exists but its comment has not translations" do
          add_translations(resource, :es)
          create(:comment, commentable: resource)

          visit send(path)

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

          visit send(path)

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

          visit send(path)

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_button "Traducir página"
        end
      end
    end

    describe "with delayed job active", :delay_jobs do
      scenario "should not be present when an equal RemoteTranslation is enqueued" do
        create(:remote_translation, remote_translatable: resource, locale: :es)
        visit send(path, locale: :es)

        expect(page).to have_content "Por favor, espera 5 segundos y actualiza la página " \
                                     "para que se muestre el contenido traducido."
        expect(page).not_to have_button "Traducir página"
      end
    end

    context "on show path" do
      let(:path) { :show_path }
      let(:factory) { (factories - [:legislation_process]).sample }

      describe "should evaluate missing translations on resource comments" do
        scenario "display when exists resource translations but the comment does not have a translation" do
          add_translations(resource, :es)
          create(:comment, commentable: resource)
          visit send(path)

          expect(page).not_to have_button "Translate page"

          select "Español", from: "Language:"

          expect(page).to have_button "Traducir página"
        end

        scenario "not display when exists resource translations but his comment has translations" do
          add_translations(resource, :es)
          create_comment_with_translations(resource, :es)
          visit send(path)

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
        visit send(path, locale: :es)

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
        visit send(path, locale: :es)

        expect(page).not_to have_content response.first

        click_button "Traducir página"

        expect(page).not_to have_button "Traducir página"
        expect(page).to have_content response.first
      end

      scenario "request a translation of an already translated text" do
        response = generate_response(resource)
        expect_any_instance_of(client).to receive(:call).and_return(response)

        in_browser(:one) do
          visit send(path, locale: :es)

          expect(page).to have_button "Traducir página"
        end

        in_browser(:two) do
          visit send(path, locale: :es)
          click_button "Traducir página"

          expect(page).to have_content "Se han solicitado correctamente las traducciones"
        end

        in_browser(:one) do
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

  def show_path(**opts)
    case factory
    when :budget_investment then budget_investment_path(resource.budget, resource, **opts)
    else polymorphic_path(resource, **opts)
    end
  end

  def index_path(**opts)
    case factory
    when :budget_investment then budget_investments_path(resource.budget, **opts)
    else polymorphic_path(collection_symbol, **opts)
    end
  end

  def home_path(**opts)
    root_path(**opts)
  end
end
