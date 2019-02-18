require "rails_helper"

describe ManagerAuthenticator do
  let(:authenticator) { described_class.new(login: "JJB033", clave_usuario: "31415926", fecha_conexion: "20151031135905") }

  describe "initialization params" do
    it "causes auth to return false if blank login" do
      blank_login_authenticator = described_class.new(login: "", clave_usuario: "31415926", fecha_conexion: "20151031135905")
      expect(blank_login_authenticator.auth).to be false
    end

    it "causes auth to return false if blank user_key" do
      blank_user_key_authenticator = described_class.new(login: "JJB033", clave_usuario: "", fecha_conexion: "20151031135905")
      expect(blank_user_key_authenticator.auth).to be false
    end

    it "causes auth to return false if blank date" do
      blank_date_authenticator = described_class.new(login: "JJB033", clave_usuario: "31415926", fecha_conexion: "")
      expect(blank_date_authenticator.auth).to be false
    end
  end

  describe "#auth" do
    it "returns false if not manager_exists" do
      allow(authenticator).to receive(:manager_exists?).and_return(false)
      allow(authenticator).to receive(:application_authorized?).and_return(true)

      expect(authenticator.auth).to be false
    end

    it "returns false if not application_authorized" do
      allow(authenticator).to receive(:manager_exists?).and_return(true)
      allow(authenticator).to receive(:application_authorized?).and_return(false)

      expect(authenticator.auth).to be false
    end

    it "returns ok if manager_exists and application_authorized" do
      allow(authenticator).to receive(:manager_exists?).and_return(true)
      allow(authenticator).to receive(:application_authorized?).and_return(true)

      expect(authenticator.auth).to be_truthy
    end
  end

  describe "SOAP" do
    it "calls the verification user method" do
      message = { ub: {user_key: "31415926", date: "20151031135905"} }
      allow(authenticator).to receive(:application_authorized?).and_return(true)
      allow(authenticator.send(:client)).to receive(:call).with(:get_status_user_data, message: message)
      authenticator.auth
    end

    it "calls the permissions check method" do
      allow(authenticator).to receive(:manager_exists?).and_return(true)
      allow(authenticator.send(:client)).to receive(:call).with(:get_applications_user_list, message: { ub: {user_key: "31415926"} })
      authenticator.auth
    end
  end
end
