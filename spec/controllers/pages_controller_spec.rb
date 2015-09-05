require 'rails_helper'

describe PagesController do

  describe 'Static pages' do
    it 'should include a privacy page' do
      get :privacy
      expect(response).to be_ok
    end

    it 'should include a conditions page' do
      get :conditions
      expect(response).to be_ok
    end

    it 'should include a general terms page' do
      get :general_terms
      expect(response).to be_ok
    end

    it 'should include a terms page' do
      get :census_terms
      expect(response).to be_ok
    end
  end

  describe 'Provisional pages' do
    it 'should include a transparency page' do
      get :transparency
      expect(response).to be_ok
    end

    it 'should include a opendata page' do
      get :opendata
      expect(response).to be_ok
    end
  end

  describe 'Info pages' do
    it 'should include a coming_soon page' do
      get :coming_soon
      expect(response).to be_ok
    end

    it 'should include a how_it_works page' do
      get :how_it_works
      expect(response).to be_ok
    end

    it 'should include a how_to_use page' do
      get :how_to_use
      expect(response).to be_ok
    end

    it 'should include a more_information page' do
      get :more_information
      expect(response).to be_ok
    end

    it 'should include a participation page' do
      get :participation
      expect(response).to be_ok
    end

    it 'should include a blog page' do
      get :blog
      expect(response).to be_redirect
    end
  end

end