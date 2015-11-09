require 'rails_helper'

describe UsersHelper do

  describe '#humanize_document_type' do
    it "should return a humanized document type" do
      expect(humanize_document_type("1")).to eq "DNI"
      expect(humanize_document_type("2")).to eq "Passport"
      expect(humanize_document_type("3")).to eq "Residence card"
    end
  end

  describe '#deleted_commentable_text' do
    it "should return the appropriate message for deleted debates" do
      debate = create(:debate)
      comment = create(:comment, commentable: debate)

      debate.hide

      expect(comment_commentable_title(comment)).to eq "<abbr title='This debate has been deleted'>#{comment.commentable.title}</abbr>"
    end

    it "should return the appropriate message for deleted proposals" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      proposal.hide

      expect(comment_commentable_title(comment)).to eq "<abbr title='This proposal has been deleted'>#{comment.commentable.title}</abbr>"
    end
  end

  describe '#comment_commentable_title' do
    it "should return a link to the commentable" do
      comment = create(:comment)
      expect(comment_commentable_title(comment)).to eq link_to comment.commentable.title, comment.commentable
    end

    it "should return a hint if the commentable has been deleted" do
      comment = create(:comment)
      comment.commentable.hide
      expect(comment_commentable_title(comment)).to eq "<abbr title='This debate has been deleted'>#{comment.commentable.title}</abbr>"
    end
  end

end
