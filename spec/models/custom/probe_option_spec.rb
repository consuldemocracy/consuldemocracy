require 'rails_helper'

describe ProbeOption do

  describe '#select' do
    before(:each) do
      @probe = Probe.create(codename: 'test_probe')
      @probe_option = @probe.probe_options.create(code: '01' , name: 'First Option')
      @user = create(:user, :level_two)
    end

    it 'should create valid user selection' do
      expect{ @probe_option.select(@user) }.to change {
        ProbeSelection.where(probe_option: @probe_option.id,
                             probe_id: @probe.id,
                             user_id: @user.id).count
      }.by(1)
    end

    it 'should not register selection if selecting is not allowed' do
      @probe.update!(selecting_allowed: false)
      expect{ @probe_option.select(@user) }.to_not change { ProbeSelection.count }
    end

    it 'removes previous user selection in the same probe' do
      second_probe_option = @probe.probe_options.create(code: '02' , name: 'Second Option')

      different_probe = Probe.create(codename: 'another_probe')
      different_probe_option = different_probe.probe_options.create(code: 'ABC' , name: 'XYZ')

      @probe_option.select(@user)
      different_probe_option.select(@user)

      expect(ProbeSelection.where(probe_id: @probe.id, user_id: @user.id).count).to eq(1)
      expect(ProbeSelection.where(probe_id: @probe.id, user_id: @user.id).first.probe_option_id).to eq(@probe_option.id)

      second_probe_option.select(@user)

      expect(ProbeSelection.where(probe_id: @probe.id, user_id: @user.id).count).to eq(1)
      expect(ProbeSelection.where(probe_id: @probe.id, user_id: @user.id).first.probe_option_id).to eq(second_probe_option.id)

      expect(ProbeSelection.where(probe_id: different_probe.id, user_id: @user.id).count).to eq(1)
      expect(ProbeSelection.where(probe_id: different_probe.id, user_id: @user.id).first.probe_option_id).to eq(different_probe_option.id)
    end

  end

  describe '#to_param' do
    it "should return a friendly url" do
      probe_option = create(:probe_option)
      expect(probe_option.to_param).to eq "#{probe_option.id} #{probe_option.name}".parameterize
    end
  end

end
