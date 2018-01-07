require 'rails_helper'

# This module tests functionality related with custom application files
# TODO test models, controllers, etc...

describe 'Customization Engine' do

  let(:test_key) { I18n.t('account.show.change_credentials_link') }
  let!(:default_path) { I18n.load_path }

  it "loads custom and override original locales" do
    I18n.load_path += Dir[Rails.root.join('spec', 'support', 'locales', 'custom', '*.{rb,yml}')]
    I18n.reload!
    expect(test_key).to eq 'Overriden string with custom locales'
  end

  it "does not override original locales" do
    I18n.load_path.delete_if {|item| item =~ /spec\/support\/locales\/custom/ }
    I18n.load_path += Dir[Rails.root.join('spec', 'support', 'locales', '**', '*.{rb,yml}')]
    I18n.reload!
    expect(test_key).to eq 'Not overriden string with custom locales'
  end

  after do
    I18n.load_path = default_path
    I18n.reload!
  end

end
