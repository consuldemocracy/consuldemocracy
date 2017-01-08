require 'rails_helper'

describe GraphQL::RootCollectionResolver do
  let(:comments_resolver) { GraphQL::RootCollectionResolver.new(Comment) }

  describe '#call' do
    it 'resolves collections' do
      comment_1 = create(:comment)
      comment_2 = create(:comment)

      result = comments_resolver.call(nil, nil, nil)

      expect(result).to match_array([comment_1, comment_2])
    end

    it 'blocks collection forbidden elements' do
      proposal = create(:proposal, :hidden)
      comment_1 = create(:comment)
      comment_2 = create(:comment, commentable: proposal)

      result = comments_resolver.call(nil, nil, nil)

      expect(result).to match_array([comment_1])
    end
  end

end
