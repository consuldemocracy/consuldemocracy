require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Comments' do

  scenario 'Index' do
    debate = create(:debate)
    3.times { create(:comment, commentable: debate) }

    visit debate_path(debate)

    expect(page).to have_css('.comment', count: 3)

    comment = Comment.first
    within first('.comment') do
      expect(page).to have_content comment.user.name
      expect(page).to have_content time_ago_in_words(comment.created_at)
      expect(page).to have_content comment.body
    end
  end

  scenario 'Paginated comments' do
    debate = create(:debate)
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:comment, commentable: debate)}

    visit debate_path(debate)

    expect(page).to have_css('.comment', count: per_page)
    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_content("2")
      expect(page).to_not have_content("3")
      click_link "Next"
    end

    expect(page).to have_css('.comment', count: 2)
  end

  feature 'Not logged user' do
    scenario 'can not see comments forms' do
      debate = create(:debate)
      create(:comment, commentable: debate)
      visit debate_path(debate)

      expect(page).to have_content 'Log in to participate'
      within('#comments') do
        expect(page).to_not have_content 'Write a comment'
        expect(page).to_not have_content 'Reply'
        expect(page).to_not have_css('form')
      end
    end
  end

  scenario 'Create', :js do
    user = create(:user)
    debate = create(:debate)

    login_as(user)
    visit debate_path(debate)

    fill_in 'comment_body', with: 'Have you thought about...?'
    click_button 'Publish comment'

    within "#comments" do
      expect(page).to have_content 'Have you thought about...?'
    end
  end

  scenario 'Errors on create', :js do
    user = create(:user)
    debate = create(:debate)

    login_as(user)
    visit debate_path(debate)

    click_button 'Publish comment'

    expect(page).to have_content "Can't be blank"
  end

  scenario 'Reply', :js do
    citizen = create(:user, first_name: 'Ana')
    manuela = create(:user, first_name: 'Manuela')
    debate  = create(:debate)
    comment = create(:comment, commentable: debate, user: citizen)

    login_as(manuela)
    visit debate_path(debate)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in 'comment_body', with: 'It will be done next week.'
      click_button 'Publish reply'
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content 'It will be done next week.'
    end

    expect(page).to_not have_selector("#js-comment-form-comment_#{comment.id}", visible: true)
  end

  scenario 'Errors on reply', :js do
    user = create(:user)
    debate = create(:debate)
    comment = create(:comment, commentable: debate, user: user)

    login_as(user)
    visit debate_path(debate)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      click_button 'Publish reply'
      expect(page).to have_content "Can't be blank"
    end

  end

  scenario "N replies", :js do
    debate = create(:debate)
    parent = create(:comment, commentable: debate)

    7.times do
      create(:comment, commentable: debate).
      move_to_child_of(parent)
      parent = parent.children.first
    end

    visit debate_path(debate)
    expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")
  end

end
