#frozen_string_literal: true

require 'rails_helper'

describe "Merchants API" do
  describe "happy path testing" do
    it "sends a lists of merchants" do
      create_list(:merchant, 3)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchants.count).to eq(3)

      merchants.each do |merchant|
        expect(merchant).to have_key :id
        expect(merchant[:id]).to be_a String

        expect(merchant[:attributes]).to have_key :name
        expect(merchant[:attributes][:name]).to be_a String
      end
    end

    it "returns an empty array when no merchants exist" do
      get "/api/v1/merchants"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response_body).to eq([])
    end

    it "returns an array when only one merchant exists" do
      create(:merchant)

      get "/api/v1/merchants"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to be_an Array
      expect(merchant.count).to eq(1)
    end

    it "can get one merchant by its id" do
      id = create(:merchant).id.to_s

      get "/api/v1/merchants/#{id}"

      expect(response).to be_successful
      
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to eq(id)

      expect(merchant[:attributes]).to have_key :name
      expect(merchant[:attributes][:name]).to be_a String
    end

    it "can list a specific merchant's items" do
      id = create(:merchant).id

      create_list(:item, 4, merchant_id: id)

      get "/api/v1/merchants/#{id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(items.count).to eq(4)
      
      items.each do |item|
        expect(item).to have_key :id
        expect(item[:id]).to be_a String

        expect(item[:attributes]).to have_key :name
        expect(item[:attributes][:name]).to be_a String

        expect(item[:attributes]).to have_key :description
        expect(item[:attributes][:description]).to be_a String
        
        expect(item[:attributes]).to have_key :unit_price
        expect(item[:attributes][:unit_price]).to be_a Float
      end
    end

    it "returns an empty array when the merchant has no items" do
      merchant_id = create(:merchant).id

      get "/api/v1/merchants/#{merchant_id}/items"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response_body).to eq([])
    end

    it "returns an array when a merchant only has one item" do
      merchant_id = create(:merchant).id
      item = create(:item, merchant_id: merchant_id)

      get "/api/v1/merchants/#{merchant_id}/items"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to be_an Array
      expect(merchant.count).to eq(1)
    end
  end

  describe "sad path testing" do
    describe "get one merchant" do
      it "returns a json error message when the merchant does not exist" do
        get "/api/v1/merchants/180984789"

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Merchant with 'id'=180984789")
      end
    end

    describe "get a merchant's items" do
      it "returns a json error message when the merchant does not exist" do
        get "/api/v1/merchants/180984789/items"

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Merchant with 'id'=180984789")
      end
    end
  end

  describe 'edge case testing' do
    describe 'get one merchant' do
      it "returns a json error message when the merchant id is a string" do
        get "/api/v1/merchants/'1809A4789'"

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Merchant with 'id'='1809A4789'")
      end
    end

    describe "get a merchant's items" do
      it "returns a json error message when the merchant id is a string" do
        get "/api/v1/merchants/'180AA4789'/items"

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Merchant with 'id'='180AA4789'")
      end
    end
  end
end