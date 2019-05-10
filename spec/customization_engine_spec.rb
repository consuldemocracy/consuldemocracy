require "rails_helper"

# This module tests functionality related with custom application files
# TODO test models, controllers, etc...

describe "Customization Engine" do

  let(:test_key)      { I18n.t("account.show.change_credentials_link") }
  let!(:default_path) { I18n.load_path }

  before do
    reset_load_path_and_reload(default_path)
  end

  after do
    reset_load_path_and_reload(default_path)
  end

  it "loads custom and override original locales" do
    increase_load_path_and_reload(Dir[Rails.root.join("spec", "support",
                                                      "locales", "custom", "*.{rb,yml}")])
    expect(test_key).to eq "Overriden string with custom locales"
  end

  it "does not override original locales" do
    increase_load_path_and_reload(Dir[Rails.root.join("spec", "support",
                                                      "locales", "*.{rb,yml}")])
    expect(test_key).to eq "Not overriden string with custom locales"
  end

  def reset_load_path_and_reload(path)
    I18n.load_path = path
    I18n.reload!
  end

  def increase_load_path_and_reload(path)
    I18n.load_path += path
    I18n.reload!
  end

end
