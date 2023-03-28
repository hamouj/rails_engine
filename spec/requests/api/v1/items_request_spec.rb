#frozen_string_literal: true

require 'rails_helper'

describe "Items API" do
  it "sends a list all items" do
    merchant_id = create(:merchant).id
    create_list(:item, 3, merchant_id: merchant_id)

    get "/api/v1/items"

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)[:data]
    
    expect(items.count).to eq(3)

    items.each do |item|
      expect(item).to have_key :id
      expect(item[:id]).to be_a String

      expect(item[:attributes]).to have_key :name
      expect(item[:attributes][:name]).to be_a String

      expect(item[:attributes]).to have_key :description
      expect(item[:attributes][:description]).to be_a String

      expect(item[:attributes]).to have_key :unit_price
      expect(item[:attributes][:unit_price]).to be_a Float

      expect(item[:attributes]).to have_key :merchant_id
      expect(item[:attributes][:merchant_id]).to be_an Integer
    end
  end

  it "can get one item by its id" do
    merchant_id = create(:merchant).id
    id = create(:item, merchant_id: merchant_id).id.to_s

    get "/api/v1/items/#{id}"

    expect(response).to be_successful

    item = JSON.parse(response.body, symbolize_names: true)[:data]

    expect(item).to have_key :id
    expect(item[:id]).to eq(id)

    expect(item[:attributes]).to have_key :name
    expect(item[:attributes][:name]).to be_a String

    expect(item[:attributes]).to have_key :description
    expect(item[:attributes][:description]).to be_a String

    expect(item[:attributes]).to have_key :unit_price
    expect(item[:attributes][:unit_price]).to be_a Float

    expect(item[:attributes]).to have_key :merchant_id
    expect(item[:attributes][:merchant_id]).to eq(merchant_id)
  end

  it "can create a new item" do
    merchant_id = create(:merchant).id
    item_params = ({
                    name: "Fancy Lamp",
                    description: "This is a very fancy lamp.",
                    unit_price: 125.33,
                    merchant_id: merchant_id
    })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can update an existing item" do
    merchant_id = create(:merchant).id
    id = create(:item, merchant_id: merchant_id).id
    previous_name = Item.last.name

    item_params = { name: 'Super Cool Lamp' }
    headers = {"CONTENT_TYPE" => "application/json"}

    put "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find(id)

    expect(response).to be_successful
    expect(item.name).to eq('Super Cool Lamp')
    expect(item.name).to_not eq(previous_name)
  end
end