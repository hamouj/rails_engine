#frozen_string_literal: true

require 'rails_helper'

describe "Item/Merchants API" do
  describe "happy path testing" do
    it "can get the merchant data for a given item ID" do
      item_merchant = create(:merchant)
      item = create(:item, merchant_id: item_merchant.id)

      get "/api/v1/items/#{item.id}/merchant"

      expect(response).to be_successful
      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to have_key :id
      expect(merchant[:id]).to eq(item_merchant.id.to_s)

      expect(merchant[:attributes]).to have_key :name
      expect(merchant[:attributes][:name]).to eq(item_merchant.name)
    end
  end

  describe "sad path testing" do
    it "returns a json error message when the item ID does not exist" do
      get "/api/v1/items/789073/merchant"

      expect(response.status).to eq(404)

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key :message
      expect(response_body[:message]).to eq("your query could not be completed")
      expect(response_body).to have_key :errors
      expect(response_body[:errors]).to be_an Array
      expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'=789073")
    end
  end

  describe "edge case testing" do
    it "returns a json error message when the item ID is entered as a string" do
      item_id = create(:item).id

      get "/api/v1/items/'#{item_id}'/merchant"

      expect(response.status).to eq(404)

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key :message
      expect(response_body[:message]).to eq("your query could not be completed")
      expect(response_body).to have_key :errors
      expect(response_body[:errors]).to be_an Array
      expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'='#{item_id}'")
    end
  end
end
