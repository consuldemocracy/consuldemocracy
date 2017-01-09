require 'rails_helper'

describe GraphQL::RootCollectionResolver do
  let(:geozones_resolver) { GraphQL::RootCollectionResolver.new(Geozone) }
  let(:comments_resolver) { GraphQL::RootCollectionResolver.new(Comment) }

  describe '#call' do
    it 'returns the whole colleciton for unscoped models' do
      geozone_1 = create(:geozone)
      geozone_2 = create(:geozone)

      result = geozones_resolver.call(nil, nil, nil)

      expect(result).to match_array([geozone_1, geozone_2])
    end

    it 'blocks forbidden elements for scoped models' do
      proposal = create(:proposal, :hidden)
      comment_1 = create(:comment)
      comment_2 = create(:comment, commentable: proposal)

      result = comments_resolver.call(nil, nil, nil)

      expect(result).to match_array([comment_1])
    end
  end

end
