require 'rails_helper'

describe GraphQL::AssociationResolver do
  let(:comments_resolver) { GraphQL::AssociationResolver.new(:comments, Comment) }
  let(:geozone_resolver)  { GraphQL::AssociationResolver.new(:geozone,  Geozone) }
  let(:geozones_resolver) { GraphQL::AssociationResolver.new(:geozones, Geozone) }

  describe '#initialize' do
    it 'sets allowed elements for unscoped models' do
      geozone_1 = create(:geozone)
      geozone_2 = create(:geozone)

      expect(geozones_resolver.allowed_elements).to match_array([geozone_1, geozone_2])
    end

    it 'sets allowed elements for scoped models' do
      public_comment = create(:comment, commentable: create(:proposal))
      restricted_comment = create(:comment, commentable: create(:proposal, :hidden))

      expect(comments_resolver.allowed_elements).to match_array([public_comment])
    end
  end

  describe '#call' do
    it 'resolves simple associations' do
      geozone = create(:geozone)
      proposal = create(:proposal, geozone: geozone)

      result = geozone_resolver.call(proposal, nil, nil)

      expect(result).to eq(geozone)
    end

    it 'blocks forbidden elements when resolving simple associations' do
      skip 'None of the current models allows this spec to be executed'
    end

    it 'resolves paginated associations' do
      proposal = create(:proposal)
      comment_1 = create(:comment, commentable: proposal)
      comment_2 = create(:comment, commentable: proposal)
      comment_3 = create(:comment, commentable: create(:proposal))

      result = comments_resolver.call(proposal, nil, nil)

      expect(result).to match_array([comment_1, comment_2])
    end

    it 'blocks forbidden elements when resolving paginated associations' do
      proposal = create(:proposal, :hidden)
      comment = create(:comment, commentable: proposal)

      result = comments_resolver.call(proposal, nil, nil)

      expect(result).to be_empty
    end
  end
  
end
