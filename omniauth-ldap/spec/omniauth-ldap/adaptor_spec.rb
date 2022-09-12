require 'spec_helper'
describe "OmniAuth::LDAP::Adaptor" do

  describe 'initialize' do
    it 'should throw exception when must have field is not set' do
      #[:host, :port, :method, :bind_dn]
      lambda { OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'plain'})}.should raise_error(ArgumentError)
    end

    it 'should throw exception when method is not supported' do
      lambda { OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'myplain', uid: 'uid', port: 389, base: 'dc=com'})}.should raise_error(OmniAuth::LDAP::Adaptor::ConfigurationError)
    end

    it 'should setup ldap connection with anonymous' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'plain', base: 'dc=intridea, dc=com', port: 389, uid: 'sAMAccountName'})
      adaptor.connection.should_not == nil
      adaptor.connection.host.should == '192.168.1.145'
      adaptor.connection.port.should == 389
      adaptor.connection.base.should == 'dc=intridea, dc=com'
      adaptor.connection.instance_variable_get('@auth').should == {:method => :anonymous, :username => nil, :password => nil}
    end

    it 'should setup ldap connection with simple' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'plain', base: 'dc=intridea, dc=com', port: 389, uid: 'sAMAccountName', bind_dn: 'bind_dn', password: 'password'})
      adaptor.connection.should_not == nil
      adaptor.connection.host.should == '192.168.1.145'
      adaptor.connection.port.should == 389
      adaptor.connection.base.should == 'dc=intridea, dc=com'
      adaptor.connection.instance_variable_get('@auth').should == {:method => :simple, :username => 'bind_dn', :password => 'password'}
    end

    it 'should setup ldap connection with sasl-md5' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'plain', base: 'dc=intridea, dc=com', port: 389, uid: 'sAMAccountName', try_sasl: true, sasl_mechanisms: ["DIGEST-MD5"], bind_dn: 'bind_dn', password: 'password'})
      adaptor.connection.should_not == nil
      adaptor.connection.host.should == '192.168.1.145'
      adaptor.connection.port.should == 389
      adaptor.connection.base.should == 'dc=intridea, dc=com'
      adaptor.connection.instance_variable_get('@auth')[:method].should == :sasl
      adaptor.connection.instance_variable_get('@auth')[:mechanism].should == 'DIGEST-MD5'
      adaptor.connection.instance_variable_get('@auth')[:initial_credential].should == ''
      adaptor.connection.instance_variable_get('@auth')[:challenge_response].should_not be_nil
    end

    it 'should setup ldap connection with sasl-gss' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'plain', base: 'dc=intridea, dc=com', port: 389, uid: 'sAMAccountName', try_sasl: true, sasl_mechanisms: ["GSS-SPNEGO"], bind_dn: 'bind_dn', password: 'password'})
      adaptor.connection.should_not == nil
      adaptor.connection.host.should == '192.168.1.145'
      adaptor.connection.port.should == 389
      adaptor.connection.base.should == 'dc=intridea, dc=com'
      adaptor.connection.instance_variable_get('@auth')[:method].should == :sasl
      adaptor.connection.instance_variable_get('@auth')[:mechanism].should == 'GSS-SPNEGO'
      adaptor.connection.instance_variable_get('@auth')[:initial_credential].should =~ /^NTLMSSP/
      adaptor.connection.instance_variable_get('@auth')[:challenge_response].should_not be_nil
    end

    it 'should set the encryption method correctly' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'tls', base: 'dc=intridea, dc=com', port: 389, uid: 'sAMAccountName'})
      adaptor.connection.instance_variable_get('@encryption').should include method: :start_tls
    end
  end

  describe 'bind_as' do
    let(:args) { {:filter => Net::LDAP::Filter.eq('sAMAccountName', 'username'), :password => 'password', :size => 1} }
    let(:rs) { Struct.new(:dn).new('new dn') }

    it 'should bind simple' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.126", method: 'plain', base: 'dc=score, dc=local', port: 389, uid: 'sAMAccountName', bind_dn: 'bind_dn', password: 'password'})
      adaptor.connection.should_receive(:open).and_yield(adaptor.connection)
      adaptor.connection.should_receive(:search).with(args).and_return([rs])
      adaptor.connection.should_receive(:bind).with({:username => 'new dn', :password => args[:password], :method => :simple}).and_return(true)
      adaptor.bind_as(args).should == rs
    end

    it 'should bind sasl' do
      adaptor = OmniAuth::LDAP::Adaptor.new({host: "192.168.1.145", method: 'plain', base: 'dc=intridea, dc=com', port: 389, uid: 'sAMAccountName', try_sasl: true, sasl_mechanisms: ["GSS-SPNEGO"], bind_dn: 'bind_dn', password: 'password'})
      adaptor.connection.should_receive(:open).and_yield(adaptor.connection)
      adaptor.connection.should_receive(:search).with(args).and_return([rs])
      adaptor.connection.should_receive(:bind).and_return(true)
      adaptor.bind_as(args).should == rs
    end
  end
end
