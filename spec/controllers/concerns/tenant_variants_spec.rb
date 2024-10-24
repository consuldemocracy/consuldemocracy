require "rails_helper"

describe TenantVariants do
  controller(ActionController::Base) do
    include TenantVariants

    def index
      render plain: request.variant
    end
  end

  it "uses the default tenant by default" do
    get :index
    expect(response.body).to eq "[:public]"
  end

  it "uses the current tenant schema when defined" do
    allow(Tenant).to receive(:current_schema).and_return("random-name")

    get :index
    expect(response.body).to eq '[:"random-name"]'
  end

  it "keeps dots in the variant names" do
    allow(Tenant).to receive(:current_schema).and_return("random.domain")

    get :index
    expect(response.body).to eq '[:"random.domain"]'
  end
end
