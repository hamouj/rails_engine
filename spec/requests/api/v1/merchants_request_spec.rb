#frozen_string_literal: true

require 'rails_helper'

describe "Merchants API" do
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
    id = create(:merchant).id.to_s

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