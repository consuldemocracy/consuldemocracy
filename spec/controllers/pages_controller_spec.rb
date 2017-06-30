require 'rails_helper'

describe PagesController do

  describe 'Static pages' do
    it 'should include a privacy page' do
      get :show, params: { id: :privacy }
      expect(response).to be_ok
    end

    it 'should include a conditions page' do
      get :show, params: { id: :conditions }
      expect(response).to be_ok
    end

    it 'should include a general terms page' do
      get :show, params: { id: :general_terms }
      expect(response).to be_ok
    end

    it 'should include a terms page' do
      get :show, params: { id: :census_terms }
      expect(response).to be_ok
    end

    it 'should include a accessibility page' do
      get :show, params: { id: :accessibility }
      expect(response).to be_ok
    end
  end

  describe 'More info pages' do

    it 'should include a more infor page' do
      get :show, params: { id: 'more_info/index' }
      expect(response).to be_ok
    end

    it 'should include a how_to_use page' do
      get :show, params: { id: 'more_info/how_to_use/index' }
      expect(response).to be_ok
    end

    it 'should include a faq page' do
      get :show, params: { id: 'more_info/faq/index' }
      expect(response).to be_ok
    end

  end

  describe 'Not found pages' do
    it 'should return a 404 message' do
      get :show, params: { id: "nonExistentPage" }
      expect(response).to be_missing
    end
  end
end
