require "rails_helper"

describe UsersHelper do

  describe "#humanize_document_type" do
    it "returns a humanized document type" do
      expect(humanize_document_type("1")).to eq "DNI"
      expect(humanize_document_type("2")).to eq "Passport"
      expect(humanize_document_type("3")).to eq "Residence card"
    end
  end

  describe "#deleted_commentable_text" do
    it "returns the appropriate message for deleted debates" do
      debate = create(:debate)
      comment = create(:comment, commentable: debate)

      debate.hide

      expect(comment_commentable_title(comment)).to eq("<del>" + comment.commentable.title +
                                                       '</del> <span class="small">(This debate has been deleted)</span>')
    end

    it "returns the appropriate message for deleted proposals" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      proposal.hide

      expect(comment_commentable_title(comment)).to eq("<del>" + comment.commentable.title +
                                                       '</del> <span class="small">(This proposal has been deleted)</span>')
    end

    it "returns the appropriate message for deleted budget investment" do
      investment = create(:budget_investment)
      comment = create(:comment, commentable: investment)

      investment.hide

      expect(comment_commentable_title(comment)).to eq("<del>" + comment.commentable.title +
                                                       '</del> <span class="small">(This investment project has been deleted)</span>')
    end
  end

  describe "#comment_commentable_title" do
    it "returns a link to the comment" do
      comment = create(:comment)
      expect(comment_commentable_title(comment)).to eq link_to comment.commentable.title, comment
    end

    it "returns a hint if the commentable has been deleted" do
      comment = create(:comment)
      comment.commentable.hide
      expect(comment_commentable_title(comment)).to eq("<del>" + comment.commentable.title +
                                                       '</del> <span class="small">(This debate has been deleted)</span>')
    end
  end

end
