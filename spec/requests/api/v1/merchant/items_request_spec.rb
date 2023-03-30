#frozen_string_literal: true

require 'rails_helper'

describe "Merchant/Items API" do
  describe "happy path testing" do
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
  end

  describe "sad path testing" do
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

  describe "edge case testing" do
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
