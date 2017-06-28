require 'rails_helper'

describe ManagerAuthenticator do
  describe 'initialization params' do
    it 'should cause auth to return false if blank login' do
      authenticator = ManagerAuthenticator.new(login: "", clave_usuario: "31415926", fecha_conexion: "20151031135905")
      expect(authenticator.auth).to be false
    end

    it 'should cause auth to return false if blank user_key' do
      authenticator = ManagerAuthenticator.new(login: "JJB033", clave_usuario: "", fecha_conexion: "20151031135905")
      expect(authenticator.auth).to be false
    end

    it 'should cause auth to return false if blank date' do
      authenticator = ManagerAuthenticator.new(login: "JJB033", clave_usuario: "31415926", fecha_conexion: "")
      expect(authenticator.auth).to be false
    end
  end

  describe '#auth' do
    before(:all) do
      @authenticator = ManagerAuthenticator.new(login: "JJB033", clave_usuario: "31415926", fecha_conexion: "20151031135905")
    end

    it 'should return false if not manager_exists' do
      allow(@authenticator).to receive(:manager_exists?).and_return(false)
      allow(@authenticator).to receive(:application_authorized?).and_return(true)

      expect(@authenticator.auth).to be false
    end

    it 'should return false if not application_authorized' do
      allow(@authenticator).to receive(:manager_exists?).and_return(true)
      allow(@authenticator).to receive(:application_authorized?).and_return(false)

      expect(@authenticator.auth).to be false
    end

    it 'should return ok if manager_exists and application_authorized' do
      allow(@authenticator).to receive(:manager_exists?).and_return(true)
      allow(@authenticator).to receive(:application_authorized?).and_return(true)

      expect(@authenticator.auth).to be_truthy
    end
  end

  describe 'SOAP' do
    before(:all) do
      @authenticator = ManagerAuthenticator.new(login: "JJB033", clave_usuario: "31415926", fecha_conexion: "20151031135905")
    end

    it 'should call the verification user method' do
      allow(@authenticator).to receive(:application_authorized?).and_return(true)
      expect(@authenticator.send(:client)).to receive(:call).with(:get_status_user_data, message: { ub: {user_key: "31415926", date: "20151031135905"} })
      @authenticator.auth
    end

    it 'should call the permissions check method' do
      allow(@authenticator).to receive(:manager_exists?).and_return(true)
      expect(@authenticator.send(:client)).to receive(:call).with(:get_applications_user_list, message: { ub: {user_key: "31415926"} })
      @authenticator.auth
    end
  end
end