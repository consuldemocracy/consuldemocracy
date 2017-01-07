require 'spec_helper'

shared_examples_for 'public_voters_stats' do
  let(:model) { described_class } # the class that includes the concern

  describe 'votes_above_threshold?' do
    let(:votable) { create(model.to_s.underscore.to_sym) }

    context 'with default threshold value' do
      it 'is true when votes are above threshold' do
        200.times { create(:vote, votable: votable) }

        expect(votable.votes_above_threshold?).to be_truthy
      end

      it 'is false when votes are under threshold' do
        199.times { create(:vote, votable: votable) }

        expect(votable.votes_above_threshold?).to be_falsey
      end
    end

    context 'with custom threshold value' do
      it 'is true when votes are above threshold' do
        create(:setting, key: "#{model.to_s.underscore}_api_votes_threshold", value: '2')
        2.times { create(:vote, votable: votable) }

        expect(votable.votes_above_threshold?).to be_truthy
      end

      it 'is false when votes are under threshold' do
        create(:setting, key: "#{model.to_s.underscore}_api_votes_threshold", value: '2')
        create(:vote, votable: votable)

        expect(votable.votes_above_threshold?).to be_falsey
      end
    end
  end
end
