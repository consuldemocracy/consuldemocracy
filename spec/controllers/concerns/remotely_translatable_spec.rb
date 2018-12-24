require 'rails_helper'

describe RemotelyTranslatable do

  class FakeResourceController < ApplicationController; end

  controller(FakeResourceController) do
    include RemotelyTranslatable

    skip_authorization_check

    def index
      @remote_translations = detect_remote_translations([Proposal.first])

      render text: "Fake text"
    end

    def show
      @commentable = Proposal.first
      @comment_tree = CommentTree.new(@commentable, params[:page], "most_voted")

      @remote_translations = detect_remote_translations([Proposal.first], @comment_tree.comments)

      render text: "Fake text"
    end
  end

  before do
    Setting["feature.remote_translations"] = true
  end

  describe 'index' do

    it "Should detect remote_translations when not defined in request locale" do
      create(:proposal)

      get :index, locale: :es

      expect(assigns(:remote_translations).count).to eq 1
    end

    it "Should not detect remote_translations when defined in request locale" do
      create(:proposal)

      get :index

      expect(assigns(:remote_translations)).to eq []
    end
  end

  describe 'show' do

    it "Should detect remote_translations when not defined in request locale" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      get :show, id: proposal.id, locale: :es

      expect(assigns(:remote_translations).count).to eq 2
    end

    it "Should not detect remote_translations when defined in request locale" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      get :show, id: proposal.id

      expect(assigns(:remote_translations)).to eq []
    end
  end
end
