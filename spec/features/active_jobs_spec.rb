require 'rails_helper'

feature 'ActiveJob' do
  include ActiveJob::TestHelper

  let(:admin) { create(:administrator) }

  scenario 'use queue to track visits' do
    debate = create(:debate)

    visit debate_path(debate)

    expect(enqueued_jobs.size).to eq(1)
    perform_enqueued_jobs { StatsJob.perform_now(enqueued_jobs.first) }

    login_as(admin.user)
    visit stats_path

    expect(page).to have_content 'Visits (1)'
  end

  scenario "use queue to track new debates" do
    user = create(:user)

    login_as(user)
    visit new_debate_path

    create_a_debate

    expect(enqueued_jobs.size).to eq(2)

    expect(enqueued_jobs.first[:args][1]["name"]).to eq("event")
    expect(enqueued_jobs.last[:args][1]["name"]).to eq("visit")

    perform_enqueued_jobs do
     enqueued_jobs.each { |job| StatsJob.perform_now(job) }
    end

    login_as(admin.user)
    visit stats_path

    expect(page).to have_content 'Debate Created (1)'
  end

end