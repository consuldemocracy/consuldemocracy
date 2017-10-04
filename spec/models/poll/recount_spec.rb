require 'rails_helper'

describe Poll::Recount do

  describe "logging changes" do
    let(:author) { create(:user) }
    let(:officer_assignment) { create(:poll_officer_assignment) }
    let(:poll_recount) { create(:poll_recount, author: author, officer_assignment: officer_assignment) }

    it "should update white_amount_log if white_amount changes" do
      poll_recount.white_amount = 33

      expect(poll_recount.white_amount_log).to eq("")

      poll_recount.white_amount = 33
      poll_recount.save
      poll_recount.white_amount = 32
      poll_recount.save
      poll_recount.white_amount = 34
      poll_recount.save

      expect(poll_recount.white_amount_log).to eq(":0:33:32")
    end

    it "should update null_amount_log if null_amount changes" do
      poll_recount.null_amount = 33

      expect(poll_recount.null_amount_log).to eq("")

      poll_recount.null_amount = 33
      poll_recount.save
      poll_recount.null_amount = 32
      poll_recount.save
      poll_recount.null_amount = 34
      poll_recount.save

      expect(poll_recount.null_amount_log).to eq(":0:33:32")
    end

    it "should update total_amount_log if total_amount changes" do
      poll_recount.total_amount = 33

      expect(poll_recount.total_amount_log).to eq("")

      poll_recount.total_amount = 33
      poll_recount.save
      poll_recount.total_amount = 32
      poll_recount.save
      poll_recount.total_amount = 34
      poll_recount.save

      expect(poll_recount.total_amount_log).to eq(":0:33:32")
    end

    it "should update officer_assignment_id_log if amount changes" do
      poll_recount.white_amount = 33

      expect(poll_recount.white_amount_log).to eq("")
      expect(poll_recount.officer_assignment_id_log).to eq("")

      poll_recount.white_amount = 33
      poll_recount.officer_assignment = create(:poll_officer_assignment, id: 101)
      poll_recount.save

      poll_recount.white_amount = 32
      poll_recount.officer_assignment = create(:poll_officer_assignment, id: 102)
      poll_recount.save

      poll_recount.white_amount = 34
      poll_recount.officer_assignment = create(:poll_officer_assignment, id: 103)
      poll_recount.save

      expect(poll_recount.white_amount_log).to eq(":0:33:32")
      expect(poll_recount.officer_assignment_id_log).to eq(":#{officer_assignment.id}:101:102")
    end

    it "should update author_id if amount changes" do
      poll_recount.white_amount = 33

      expect(poll_recount.white_amount_log).to eq("")
      expect(poll_recount.author_id_log).to eq("")

      first_author = create(:poll_officer).user
      second_author = create(:poll_officer).user
      third_author = create(:poll_officer).user

      poll_recount.white_amount = 33
      poll_recount.author_id = first_author.id
      poll_recount.save!

      poll_recount.white_amount = 32
      poll_recount.author_id = second_author.id
      poll_recount.save!

      poll_recount.white_amount = 34
      poll_recount.author_id = third_author.id
      poll_recount.save!

      expect(poll_recount.white_amount_log).to eq(":0:33:32")
      expect(poll_recount.author_id_log).to eq(":#{author.id}:#{first_author.id}:#{second_author.id}")
    end
  end

end
