require 'rails_helper'
include ActionView::Helpers::DateHelper

feature 'Commenting legislation questions' do
  let(:user) { create :user }
  let(:legislation_annotation) { create :legislation_annotation, author: user }

  # TODO
  xscenario 'Creation date works differently in roots and in child comments, even when sorting by confidence_score' do
    old_root = create(:comment, commentable: legislation_annotation, created_at: Time.current - 10)
    new_root = create(:comment, commentable: legislation_annotation, created_at: Time.current)
    old_child = create(:comment, commentable: legislation_annotation, parent_id: new_root.id, created_at: Time.current - 10)
    new_child = create(:comment, commentable: legislation_annotation, parent_id: new_root.id, created_at: Time.current)

    visit legislation_process_draft_version_annotation_path(legislation_annotation.draft_version.process,
                                                            legislation_annotation.draft_version,
                                                            legislation_annotation,
                                                            order: :most_voted)

    expect(new_root.body).to appear_before(old_root.body)
    expect(old_child.body).to appear_before(new_child.body)

    visit legislation_process_draft_version_annotation_path(legislation_annotation.draft_version.process,
                                                            legislation_annotation.draft_version,
                                                            legislation_annotation,
                                                            order: :newest)

    expect(new_root.body).to appear_before(old_root.body)
    expect(new_child.body).to appear_before(old_child.body)

    visit legislation_process_draft_version_annotation_path(legislation_annotation.draft_version.process,
                                                            legislation_annotation.draft_version,
                                                            legislation_annotation,
                                                            order: :oldest)

    expect(old_root.body).to appear_before(new_root.body)
    expect(old_child.body).to appear_before(new_child.body)
  end

  feature 'Voting comments' do
    background do
      @manuela = create(:user, verified_at: Time.current)
      @pablo = create(:user)
      @legislation_annotation = create(:legislation_annotation)
      @comment = create(:comment, commentable: @legislation_annotation)

      login_as(@manuela)
    end

    scenario 'Trying to vote multiple times', :js do
      visit legislation_process_draft_version_annotation_path(@legislation_annotation.draft_version.process,
                                                              @legislation_annotation.draft_version,
                                                              @legislation_annotation)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        within('.in_favor') do
          expect(page).to have_content "1"
        end

        find('.in_favor a').click
        within('.in_favor') do
          expect(page).not_to have_content "2"
          expect(page).to have_content "0"
        end

        within('.against') do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end


end
