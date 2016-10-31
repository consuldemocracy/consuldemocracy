# coding: utf-8
require 'rails_helper'

feature 'Polls' do

  scenario 'Polls can be listed' do
    polls = create_list(:poll, 3)

    visit polls_path

    polls.each do |poll|
      expect(page).to have_link(poll.name)
    end
  end

  scenario 'Polls can be seen' do
    poll = create(:poll)
    visit poll_path(poll)
    expect(page).to have_content(poll.name)
  end
end

