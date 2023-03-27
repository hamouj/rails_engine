#frozen_string_literal: true

require 'rails_helper'

describe "Merchants API" do
  it "sends a lists of books" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expect(merchant).to have_key :id
      expect(merchant[:id]).to be_an Integer

      expect(merchant).to have_key :name
      expect(merchant[:name]).to be_a String

      expect(merchant).to have_key :created_at
      expect(merchant[:created_at]).to be_a String

      expect(merchant).to have_key :updated_at
      expect(merchant[:updated_at]).to be_a String
    end
  end

  it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    expect(response).to be_successful
    
    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(merchant).to have_key(:id)
    expect(merchant[:id]).to eq(id)

    expect(merchant).to have_key :name
    expect(merchant[:name]).to be_a String

    expect(merchant).to have_key :created_at
    expect(merchant[:created_at]).to be_a String

    expect(merchant).to have_key :updated_at
    expect(merchant[:updated_at]).to be_a String
  end
end