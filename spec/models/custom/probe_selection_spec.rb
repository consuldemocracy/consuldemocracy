require 'rails_helper'

describe ProbeSelection do

  before(:each) do
    @probe = Probe.create(codename: 'test_probe')
    @probe_option = @probe.probe_options.create(code: '01' , name: 'First Option')
    @user = create(:user, :level_two)

    @probe_selection = ProbeSelection.create(probe: @probe, probe_option: @probe_option, user: @user)
  end


  it 'should validate uniqness of probe_option by user and probe' do
    expect(ProbeSelection.new(probe: @probe,
                              probe_option: @probe_option,
                              user: @user)
          ).to_not be_valid

    expect(ProbeSelection.new(probe: Probe.create(codename: 'New'),
                              probe_option: @probe_option,
                              user: @user)
          ).to be_valid

    expect(ProbeSelection.new(probe: @probe,
                              probe_option: @probe_option,
                              user: create(:user, :level_two))
          ).to be_valid

    expect(ProbeSelection.new(probe: @probe,
                              probe_option: @probe.probe_options.create(code: '02' , name: 'Last Option'),
                              user: @user)
          ).to be_valid
  end

end