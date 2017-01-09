require 'rails_helper'

describe GraphQL::RootElementResolver do
  let(:comment_resolver) { GraphQL::RootElementResolver.new(Comment) }
  let(:geozone_resolver) { GraphQL::RootElementResolver.new(Geozone) }

  describe '#call' do

    it 'resolves simple elements' do
      comment = create(:comment)

      result = comment_resolver.call(nil, {'id' => comment.id}, nil)

      expect(result).to eq(comment)
    end

    it 'returns nil when requested element is forbidden' do
      proposal = create(:proposal, :hidden)
      comment = create(:comment, commentable: proposal)

      result = comment_resolver.call(nil, {'id' => comment.id}, nil)

      expect(result).to be_nil
    end

    it 'returns nil when requested element does not exist' do
      result = comment_resolver.call(nil, {'id' => 1}, nil)

      expect(result).to be_nil
    end

    it 'uses the public_for_api scope when available' do
      geozone = create(:geozone)
      comment = create(:comment, commentable: create(:proposal, :hidden))

      geozone_result = geozone_resolver.call(nil, {'id' => geozone.id}, nil)
      comment_result = comment_resolver.call(nil, {'id' => comment.id}, nil)

      expect(geozone_result).to eq(geozone)
      expect(comment_result).to be_nil
    end
  end

end
