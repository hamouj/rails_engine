#frozen_string_literal: true

require 'rails_helper'

describe "Items API" do
  describe "happy path testing" do
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

    it "returns an empty array when no items exist" do
      get "/api/v1/items"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)[:data]
      
      expect(response_body).to eq([])
    end

    it "returns an array when only one item exists" do
      create(:item)

      get "/api/v1/items"

      expect(response).to be_successful

      merchant = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(merchant).to be_an Array
      expect(merchant.count).to eq(1)
    end

    it "can get one item by its id" do
      merchant_id = create(:merchant).id
      id = create(:item, merchant_id: merchant_id).id

      get "/api/v1/items/#{id}"

      item = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(item).to have_key :id
      expect(item[:id]).to eq(id.to_s)

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

    it "changes a given string to an integer/float and creates the item" do
      merchant_id = create(:merchant).id
      item_params = ({
                      name: "Fancy Lamp",
                      description: "This is a very fancy lamp.",
                      unit_price: "125.33",
                      merchant_id: merchant_id.to_s
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      created_item = Item.last

      expect(response).to be_successful
      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price).to eq(item_params[:unit_price].to_f)
      expect(created_item.merchant_id).to eq(item_params[:merchant_id].to_i)
    end

    it "can update an existing item when given partial attributes" do
      merchant_id = create(:merchant).id
      id = create(:item, merchant_id: merchant_id).id
      previous_name = Item.last.name

      item_params = { name: 'Super Cool Lamp' }
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({ item: item_params })
      item = Item.find(id)

      expect(response).to be_successful
      expect(item.name).to eq('Super Cool Lamp')
      expect(item.name).to_not eq(previous_name)
    end

    it "can update an existing item with all new information" do
      merchant_id = create(:merchant).id
      merchant2_id = create(:merchant).id
      id = create(:item, merchant_id: merchant_id).id
      previous_data = Item.last

      item_params = ({
                      name: "Awesome Lamp",
                      description: "This is the awesomest lamp.",
                      unit_price: 12.50,
                      merchant_id: merchant2_id
      })

      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
      item = Item.find(id)

      expect(response).to be_successful
      expect(item.name).to eq("Awesome Lamp")
      expect(item.name).to_not eq(previous_data.name)

      expect(item.description).to eq("This is the awesomest lamp.")
      expect(item.description).to_not eq(previous_data.description)

      expect(item.unit_price).to eq(12.50)
      expect(item.unit_price).to_not eq(previous_data.unit_price)

      expect(item.merchant_id).to eq(merchant2_id)
      expect(item.merchant_id).to_not eq(previous_data.merchant_id)
    end

    it "can destroy an item" do
      merchant_id = create(:merchant).id
      item = create(:item, merchant_id: merchant_id)
      
      delete "/api/v1/items/#{item.id}"

      expect(response.status).to eq(204)
      expect(response.body).to eq("")
      expect(Item.count).to eq(0)
      expect{ Item.find(item.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "destroys an invoice if the destroyed item was the only item on the invoice" do
      customer_id = create(:customer).id
      merchant_id = create(:merchant).id

      item1 = create(:item, merchant_id: merchant_id)
      item2 = create(:item, merchant_id: merchant_id)

      invoice1 = create(:invoice, merchant_id: merchant_id, customer_id: customer_id)
      create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id)

      invoice2 = create(:invoice, merchant_id: merchant_id, customer_id: customer_id)
      create(:invoice_item, item_id: item1.id, invoice_id: invoice2.id)
      create(:invoice_item, item_id: item2.id, invoice_id: invoice2.id)

      expect(Item.count).to eq(2)
      expect(Invoice.count).to eq(2)

      delete "/api/v1/items/#{item1.id}"

      expect(response.status).to eq(204)
      expect(Item.count).to eq(1)
      expect{ Item.find(item1.id) }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Invoice.count).to eq(1)
      expect{ Invoice.find(invoice1.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "destroys multiple invoices if the destroyed item was the only item on the invoice" do
      customer_id = create(:customer).id
      merchant_id = create(:merchant).id

      item1 = create(:item, merchant_id: merchant_id)
      item2 = create(:item, merchant_id: merchant_id)

      invoice1 = create(:invoice, merchant_id: merchant_id, customer_id: customer_id)
      create(:invoice_item, item_id: item1.id, invoice_id: invoice1.id)

      invoice2 = create(:invoice, merchant_id: merchant_id, customer_id: customer_id)
      create(:invoice_item, item_id: item1.id, invoice_id: invoice2.id)
      create(:invoice_item, item_id: item2.id, invoice_id: invoice2.id)

      invoice3 = create(:invoice, merchant_id: merchant_id, customer_id: customer_id)
      create(:invoice_item, item_id: item1.id, invoice_id: invoice3.id)

      expect(Item.count).to eq(2)
      expect(Invoice.count).to eq(3)

      delete "/api/v1/items/#{item1.id}"

      expect(response.status).to eq(204)
      expect(Item.count).to eq(1)
      expect{ Item.find(item1.id) }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Invoice.count).to eq(1)
      expect{ Invoice.find(invoice1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect{ Invoice.find(invoice3.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "sad path testing" do
    describe "get one item" do
      it "returns a json error message when the item does not exist" do
        get "/api/v1/items/180984789"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'=180984789")
      end
    end

    describe "create an item" do
      it "returns a json error message when one attribute is missing" do
        item_params = ({
                        name: "Fancy Lamp",
                        description: "This is a very fancy lamp.",
                        unit_price: 125.33
        })
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Validation failed: Merchant must exist")
      end

      it "returns a json error message when more than one attribute is missing" do
        item_params = ({
                        name: "Fancy Lamp",
                        description: "This is a very fancy lamp."
        })
        headers = {"CONTENT_TYPE" => "application/json"}

        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Validation failed: Merchant must exist")
        expect(response_body[:errors].second).to eq("Unit price can't be blank")
        expect(response_body[:errors].last).to eq("Unit price is not a number")
      end
    end

    describe "update an item" do
      it "returns a json error message when the item ID does not exist" do
        patch "/api/v1/items/5678934"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'=5678934")
      end
    end

    describe "delete an item" do
      it "returns a json error message when the item ID does not exist" do
        delete "/api/v1/items/5678934"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'=5678934")
      end
    end
  end

  describe "edge case testing" do
    describe "get one item" do
      it "returns a json error message when the item id is a string" do
        item_id = create(:item).id
        get "/api/v1/items/'#{item_id}'"

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'='#{item_id}'")
      end
    end

    describe "create an item" do
      it "returns a json error when an array is entered as the unit price" do
        merchant_id = create(:merchant).id
        item_params = ({
                        name: "Fancy Lamp",
                        description: "This is a very fancy lamp.",
                        unit_price: [125, 33.5],
                        merchant_id: merchant_id
        })
        headers = {"CONTENT_TYPE" => "application/json"}
  
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Validation failed: Unit price can't be blank")
        expect(response_body[:errors].second).to eq("Unit price is not a number")
      end

      it "returns a json error when a negative number is entered as the unit price" do
        merchant_id = create(:merchant).id
        item_params = ({
                        name: "Fancy Lamp",
                        description: "This is a very fancy lamp.",
                        unit_price: -35.67,
                        merchant_id: merchant_id
        })
        headers = {"CONTENT_TYPE" => "application/json"}
  
        post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Validation failed: Unit price must be greater than 0")
      end
    end

    describe "update an item" do
      it "returns a json error message when the merchant ID does not exist" do
        merchant_id = create(:merchant).id
        id = create(:item, merchant_id: merchant_id).id
  
        item_params = { merchant_id: "458973" }
        headers = {"CONTENT_TYPE" => "application/json"}
  
        patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({ item: item_params })
        
        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Validation failed: Merchant must exist")
      end

      it "return a json error message when the item ID is entered as a string" do
        item_id = create(:item).id
        patch "/api/v1/items/'#{item_id}'"
    
        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Couldn't find Item with 'id'='#{item_id}'")
      end

      it "returns a json error when a negative number is entered as the unit price" do
        merchant_id = create(:merchant).id
        id = create(:item, merchant_id: merchant_id).id

        item_params = ({
                        unit_price: -35.67,
                        merchant_id: merchant_id
        })
        headers = {"CONTENT_TYPE" => "application/json"}
  
        patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item: item_params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        expect(response_body).to have_key :errors
        expect(response_body[:errors]).to be_an Array
        expect(response_body[:errors].first).to eq("Validation failed: Unit price must be greater than 0")
      end
    end

    describe "delete an item" do
      it "returns a json error message when the item ID is entered as a string" do
        item_id = create(:item).id
        delete "/api/v1/items/'#{item_id}'"

        expect(response).to_not be_successful
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
end
