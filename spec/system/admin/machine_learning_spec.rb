require "rails_helper"

describe "Machine learning" do
  let(:admin) { create(:administrator) }

  before do
    login_as(admin.user)
    Setting["feature.machine_learning"] = true
  end

  scenario "Section does not appear if feature is not enabled" do
    Setting["feature.machine_learning"] = false

    visit admin_root_path

    within "#admin_menu" do
      expect(page).not_to have_link "AI / Machine learning"
    end
  end

  scenario "Section appears if feature is enabled" do
    visit admin_root_path

    within "#admin_menu" do
      expect(page).to have_link "AI / Machine learning"
    end

    click_link "AI / Machine learning"

    expect(page).to have_content "AI / Machine learning"
    expect(page).to have_content "This functionality is experimental"
    expect(page).to have_link "Execute script"
    expect(page).to have_link "Settings / Generated content"
    expect(page).to have_link "Help"
    expect(page).to have_current_path(admin_machine_learning_path)
  end

  scenario "Show message if feature is disabled" do
    Setting["feature.machine_learning"] = false

    visit admin_machine_learning_path

    expect(page).to have_content "This feature is disabled. To use Machine Learning you can enable it from " \
                                 "the settings page"
    expect(page).to have_link "settings page", href: admin_settings_path(anchor: "tab-feature-flags")
  end

  scenario "Script executed sucessfully" do
    allow_any_instance_of(MachineLearning).to receive(:run) do
      MachineLearningJob.first.update!(finished_at: Time.current)
    end

    visit admin_machine_learning_path

    select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"
    click_button "Execute script"

    expect(page).to have_content "The last script has been executed successfully."
    expect(page).to have_content "You will receive an email in #{admin.email} when the script " \
                                 "finishes running."

    expect(page).to have_field "Select python script to execute"
    expect(page).to have_button "Execute script"
  end

  scenario "Settings" do
    visit admin_machine_learning_path

    within "#machine_learning_tabs" do
      click_link "Settings / Generated content"
    end

    expect(page).to have_content "Related content"
    expect(page).to have_content "Adds automatically generated related content to proposals and " \
                                 "participatory budget projects"

    expect(page).to have_content "Comments summary"
    expect(page).to have_content "Displays an automatically generated comment summary on all items that " \
                                 "can be commented on."

    expect(page).to have_content "Tags"
    expect(page).to have_content "Generates automatic tags on all items that can be tagged on."

    expect(page).to have_content "No content generated yet", count: 3
    expect(page).not_to have_button "Yes"
    expect(page).not_to have_button "No"
  end

  scenario "Script started but not finished yet" do
    allow_any_instance_of(MachineLearning).to receive(:run)

    visit admin_machine_learning_path

    select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"
    click_button "Execute script"

    expect(page).to have_content "The script is running. The administrator who executed it will receive " \
                                 "an email when it is finished."

    expect(page).to have_content "Executed by: #{admin.name}"
    expect(page).to have_content "Script name: proposals_related_content_and_tags_nmf.py"
    expect(page).to have_content "Started at:"

    expect(page).not_to have_content "Select python script to execute"
    expect(page).not_to have_button "Execute script"
  end

  scenario "Admin can cancel operation if script is working for too long" do
    allow_any_instance_of(MachineLearning).to receive(:run) do
      MachineLearningJob.first.update!(started_at: 25.hours.ago)
    end

    visit admin_machine_learning_path

    select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"
    click_button "Execute script"

    accept_confirm { click_button "Cancel operation" }

    expect(page).to have_content "Generated content has been successfully deleted."

    expect(page).to have_field "Select python script to execute"
    expect(page).to have_button "Execute script"
  end

  scenario "Script finished with an error" do
    allow_any_instance_of(MachineLearning).to receive(:run) do
      MachineLearningJob.first.update!(finished_at: Time.current, error: "Error description")
    end

    visit admin_machine_learning_path

    select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"
    click_button "Execute script"

    expect(page).to have_content "An error has occurred. You can see the details below."

    expect(page).to have_content "Executed by: #{admin.name}"
    expect(page).to have_content "Script name: proposals_related_content_and_tags_nmf.py"
    expect(page).to have_content "Error: Error description"

    expect(page).to have_content "You will receive an email in #{admin.email} when the script " \
                                 "finishes running."

    expect(page).to have_field "Select python script to execute"
    expect(page).to have_button "Execute script"
  end

  scenario "Machine Learning visualization settings are disabled by default" do
    allow_any_instance_of(MachineLearning).to receive(:run) do
      MachineLearningJob.first.update!(finished_at: Time.current)
    end

    visit admin_machine_learning_path

    select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"
    click_button "Execute script"

    expect(page).to have_content "The last script has been executed successfully."

    within "#machine_learning_tabs" do
      click_link "Settings / Generated content"
    end

    expect(page).to have_content "No content generated yet", count: 3
    expect(page).not_to have_button "Yes"
    expect(page).not_to have_button "No"
  end

  scenario "Show script descriptions" do
    visit admin_machine_learning_path

    select "proposals_summary_comments_textrank.py", from: "Select python script to execute"

    within "#script_descriptions" do
      expect(page).to have_content "Proposals comments summaries"
    end

    select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"

    within "#script_descriptions" do
      expect(page).to have_content "Related Proposals and Tags"
      expect(page).not_to have_content "Proposals comments summaries"
    end
  end

  scenario "Show output files info on settins page" do
    FileUtils.mkdir_p MachineLearning.data_folder

    allow_any_instance_of(MachineLearning).to receive(:run) do
      MachineLearningJob.first.update!(finished_at: 2.minutes.from_now)
      create(:machine_learning_info,
             script: "proposals_summary_comments_textrank.py",
             kind: "comments_summary",
             updated_at: 2.minutes.from_now)
      comments_file = MachineLearning.data_folder.join(MachineLearning.comments_filename)
      File.write(comments_file, [].to_json)
      proposals_comments_summary_file = MachineLearning
                                        .data_folder
                                        .join(MachineLearning.proposals_comments_summary_filename)
      File.write(proposals_comments_summary_file, [].to_json)
    end

    visit admin_machine_learning_path

    within "#machine_learning_tabs" do
      click_link "Settings / Generated content"
    end

    expect(page).to have_content "No content generated yet.", count: 3

    within "#machine_learning_tabs" do
      click_link "Execute script"
    end

    travel_to(Time.zone.local(2019, 10, 20, 14, 57, 25)) do
      select "proposals_related_content_and_tags_nmf.py", from: "Select python script to execute"
      click_button "Execute script"

      expect(page).to have_content "The last script has been executed successfully."
    end

    within "#machine_learning_tabs" do
      click_link "Settings / Generated content"
    end

    expect(page).to have_content "Last execution\n2019-10-20 14:57 - 2019-10-20 14:59"
    expect(page).to have_content "Executed script:"
    expect(page).to have_content "proposals_summary_comments_textrank.py"
    expect(page).to have_content "Output files:"
    expect(page).to have_link "ml_comments_summaries_proposals.json",
                              href: "/machine_learning/data/ml_comments_summaries_proposals.json"
  end
end
