require "rails_helper"

describe "Imports", :admin do
  let(:base_files_path) { "local_census_records/import/" }

  describe "New" do
    scenario "Should show import form" do
      visit new_admin_local_census_records_import_path

      expect(page).to have_field("local_census_records_import_file", type: "file")
    end
  end

  describe "Create" do
    before { visit new_admin_local_census_records_import_path }

    scenario "Should show success notice after successful import" do
      within "form#new_local_census_records_import" do
        path = base_files_path + "valid.csv"
        file = file_fixture(path)
        attach_file("local_census_records_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Local census records import process executed successfully!"
    end

    scenario "Should show alert when file is not present" do
      within "form#new_local_census_records_import" do
        click_button "Save"
      end

      expect(page).to have_content "can't be blank"
    end

    scenario "Should show alert when file is not supported" do
      within "form#new_local_census_records_import" do
        file = file_fixture("clippy.jpg")
        attach_file("local_census_records_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Given file format is wrong. The allowed file format is: csv."
    end

    scenario "Should show successfully created local census records at created group" do
      within "form#new_local_census_records_import" do
        path = base_files_path + "valid.csv"
        file = file_fixture(path)
        attach_file("local_census_records_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Created records (4)"
      expect(page).to have_css "#created-local-census-records tbody tr", count: 4
    end

    scenario "Should show invalid local census records at errored group" do
      within "form#new_local_census_records_import" do
        path = base_files_path + "invalid.csv"
        file = file_fixture(path)
        attach_file("local_census_records_import_file", file)
        click_button "Save"
      end

      expect(page).to have_content "Errored rows (5)"
      expect(page).to have_css "#invalid-local-census-records tbody tr", count: 5
    end

    scenario "Should show error messages inside cells at errored group" do
      within "form#new_local_census_records_import" do
        path = base_files_path + "invalid.csv"
        file = file_fixture(path)
        attach_file("local_census_records_import_file", file)
        click_button "Save"
      end
      rows = all("#invalid-local-census-records tbody tr")
      expect(rows[0]).to have_content("can't be blank")
      expect(rows[1]).to have_content("can't be blank")
      expect(rows[2]).to have_content("can't be blank")
      expect(rows[3]).to have_content("can't be blank")
    end
  end
end
