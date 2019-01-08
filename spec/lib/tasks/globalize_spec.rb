require "rails_helper"

describe "Globalize tasks" do

  describe "#migrate_data" do

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

    context "Invalid data" do
      let!(:valid_process) do
        create(:legislation_process).tap do |process|
          process.translations.delete_all
          process.update_column(:title, "Title")
          process.reload
        end
      end

      let!(:invalid_process) do
        create(:legislation_process).tap do |process|
          process.translations.delete_all
          process.update_column(:title, "")
          process.reload
        end
      end

      it "ignores invalid data and migrates valid data" do
        expect(valid_process).to be_valid
        expect(invalid_process).not_to be_valid

        run_rake_task

        expect(valid_process.translations.count).to eq 1
        expect(valid_process.reload.title).to eq "Title"

        expect(invalid_process.translations.count).to eq 0
        expect(invalid_process.reload.title).to eq ""
      end
    end

    context "locale with non-underscored name" do
      before { I18n.locale = :"pt-BR" }

      let!(:milestone) do
        create(:milestone).tap do |milestone|
          milestone.translations.delete_all
          milestone.update_column(:title, "Português")
          milestone.reload
        end
      end

      it "runs the migration successfully" do
        run_rake_task

        expect(milestone.reload.title).to eq "Português"
      end
    end
  end
end
