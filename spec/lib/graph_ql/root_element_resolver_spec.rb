require 'rails_helper'

describe GraphQL::RootElementResolver do
  let(:comment_resolver) { GraphQL::RootElementResolver.new(Comment) }

  describe '#call' do
    it 'resolves simple elements' do
      comment = create(:comment)
      arguments = { 'id' => comment.id }

      result = comment_resolver.call(nil, arguments, nil)

      expect(result).to eq(comment)
    end

    it 'returns nil when requested element is forbidden' do
      proposal = create(:proposal, :hidden)
      comment = create(:comment, commentable: proposal)
      arguments = { 'id' => comment.id }

      result = comment_resolver.call(nil, arguments, nil)

      expect(result).to be_nil
    end

    it 'returns nil when requested element does not exist' do
      arguments = { 'id' => 1 }

      result = comment_resolver.call(nil, arguments, nil)

      expect(result).to be_nil
    end
  end

end
