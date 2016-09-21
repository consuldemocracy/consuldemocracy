require 'rails_helper'

describe ProbeOption do

  describe '#register_vote' do
    before(:each) do
      @probe = Probe.create(codename: 'test_probe')
      @probe_option = @probe.probe_options.create(code: '01' , name: 'First Option')
      @user = create(:user, :level_two)
    end

    it 'should register valid user vote' do
      expect{ @probe_option.register_vote(@user, 'yes') }.to change { @probe_option.cached_votes_up }.by(1)
    end

    it 'should not register vote if voting is not allowed' do
      @probe.update!(voting_allowed: false)
      expect{ @probe_option.register_vote(@user, 'yes') }.to_not change { @probe_option.cached_votes_up }
    end

    it 'removes previous user votes in the same probe' do
      second_probe_option = @probe.probe_options.create(code: '02' , name: 'Second Option')

      different_probe = Probe.create(codename: 'another_probe')
      different_probe_option = different_probe.probe_options.create(code: 'ABC' , name: 'XYZ')

      @probe_option.register_vote(@user, 'yes')
      different_probe_option.register_vote(@user, 'yes')

      expect(second_probe_option.reload.cached_votes_up).to eq(0)
      expect(@probe_option.reload.cached_votes_up).to eq(1)
      expect(different_probe_option.reload.cached_votes_up).to eq(1)

      second_probe_option.register_vote(@user, 'yes')

      expect(second_probe_option.reload.cached_votes_up).to eq(1)
      expect(@probe_option.reload.cached_votes_up).to eq(0)
      expect(different_probe_option.reload.cached_votes_up).to eq(1)
    end

  end
end