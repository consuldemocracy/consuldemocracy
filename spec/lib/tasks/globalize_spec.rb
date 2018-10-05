require "rails_helper"
require "rake"

describe "Globalize tasks" do

  describe "#migrate_data" do

    before do
      Rake.application.rake_require "tasks/globalize"
      Rake::Task.define_task(:environment)
    end

    let :run_rake_task do
      Rake::Task["globalize:migrate_data"].reenable
      Rake.application.invoke_task "globalize:migrate_data"
    end

    context "Original data with no translated data" do
      let(:poll) do
        create(:poll).tap do |poll|
          poll.translations.delete_all
          poll.update_column(:name, "Original")
          poll.reload
        end
      end

      it "copies the original data" do
        expect(poll.send(:"name_#{I18n.locale}")).to be nil
        expect(poll.name).to eq("Original")

        run_rake_task
        poll.reload

        expect(poll.name).to eq("Original")
        expect(poll.send(:"name_#{I18n.locale}")).to eq("Original")
      end
    end

    context "Original data with blank translated data" do
      let(:banner) do
        create(:banner).tap do |banner|
          banner.update_column(:title, "Original")
          banner.translations.first.update_column(:title, "")
        end
      end

      it "copies the original data" do
        expect(banner.title).to eq("")

        run_rake_task
        banner.reload

        expect(banner.title).to eq("Original")
        expect(banner.send(:"title_#{I18n.locale}")).to eq("Original")
      end
    end

    context "Original data with translated data" do
      let(:notification) do
        create(:admin_notification, title: "Translated").tap do |notification|
          notification.update_column(:title, "Original")
        end
      end

      it "maintains the translated data" do
        expect(notification.title).to eq("Translated")

        run_rake_task
        notification.reload

        expect(notification.title).to eq("Translated")
        expect(notification.send(:"title_#{I18n.locale}")).to eq("Translated")
      end
    end

    context "Custom page with a different locale and no translations" do
      let(:page) do
        create(:site_customization_page, locale: :fr).tap do |page|
          page.translations.delete_all
          page.update_column(:title, "en Français")
          page.reload
        end
      end

      it "copies the original data to both the page's locale" do
        expect(page.title).to eq("en Français")
        expect(page.title_fr).to be nil
        expect(page.send(:"title_#{I18n.locale}")).to be nil

        run_rake_task
        page.reload

        expect(page.title).to eq("en Français")
        expect(page.title_fr).to eq("en Français")
        expect(page.send(:"title_#{I18n.locale}")).to be nil
      end
    end

    context "Custom page with a different locale and existing translations" do
      let(:page) do
        create(:site_customization_page, title: "In English", locale: :fr).tap do |page|
          page.update_column(:title, "en Français")
        end
      end

      it "copies the original data to the page's locale" do
        expect(page.title_fr).to be nil
        expect(page.title).to eq("In English")

        run_rake_task
        page.reload

        expect(page.title).to eq("In English")
        expect(page.title_fr).to eq("en Français")
        expect(page.send(:"title_#{I18n.locale}")).to eq("In English")
      end
    end
  end
end
