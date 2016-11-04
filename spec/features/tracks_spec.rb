require 'rails_helper'

feature 'Tracking' do

  context 'Page view' do
    scenario 'Url'
    scenario 'Referer'
    scenario 'Title'
  end

  context 'User data' do

    context 'Verification level' do
      scenario 'Level 1'
      scenario 'Level 2'
      scenario 'Level 3'
    end

    context 'Demographics' do
      scenario 'Age'
      scenario 'Gender'
      scenario 'District'
    end

  end

  context 'Events' do
    scenario 'Login'
    scenario 'Registration'
    scenario 'Up vote a debate'
    scenario 'Down vote a debate'
    scenario 'Support a proposal'
    scenario 'Create a proposal'
    scenario 'Comment a proposal'
    scenario 'Share propoposal'
    scenario 'Verify census'
    scenario 'Verify sms'
    scenario 'Delete account'
  end

end
