#frozen_string_literal: true

require "rails_helper"

describe "Find API" do
  describe "happy path testing" do
    it "returns a merchant by a partial name match" do
      merchant = create(:merchant, name: 'Jasmine')
      
      get "/api/v1/merchants/find?name=Jas"
        
      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response_body).to have_key :id
      expect(response_body[:id]).to eq(merchant.id.to_s)
      
      expect(response_body[:attributes]).to have_key :name
      expect(response_body[:attributes][:name]).to eq(merchant.name)
    end

    it "returns all items by a partial name match" do
      item1 = create(:item, name: 'Cool lAMp')
      item2 = create(:item, name: 'Namaste shirt')
      item3 = create(:item, name: 'fondue set')

      get "/api/v1/items/find_all?name=am"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)[:data]

      expect(response_body.count).to eq(2)
      expect(response_body).to be_an Array

      expect(response_body[0]).to have_key :id
      expect(response_body[0][:id]).to eq(item1.id.to_s)
      
      expect(response_body[0][:attributes]).to have_key :name
      expect(response_body[0][:attributes][:name]).to eq(item1.name)

      expect(response_body[1]).to have_key :id
      expect(response_body[1][:id]).to eq(item2.id.to_s)
      
      expect(response_body[1][:attributes]).to have_key :name
      expect(response_body[1][:attributes][:name]).to eq(item2.name)
    end
  end

  describe "sad path testing" do
    describe "find one merchant by name" do
      it "returns an empty hash when there is no match" do
        get "/api/v1/merchants/find?name=NOMATCH"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to eq({})
      end
    end

    describe "find all items by name" do
      it "returns an empty array when there is no match" do
        get "/api/v1/items/find_all?name=NOMATCH"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to be_an Array
        expect(response_body[:data].count).to eq(0)
      end

      it "returns a single item within an array when there is only on match" do
        item = create(:item, name: 'nocturnal owl')

        get "/api/v1/items/find_all?name=NO"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to be_an Array
        expect(response_body[:data].count).to eq(1)
      end
    end
  end

  describe "edge case testing" do
    describe "find one merchant by name" do
      it "returns a json error when the parameters are missing" do
        get "/api/v1/merchants/find"

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end

      it "returns a json error when the parameters are empty" do
        get "/api/v1/merchants/find?name="

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end
    end

    describe "find all items by name" do
      it "returns a json error when the parameters are missing" do
        get "/api/v1/items/find_all"

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end

      it "returns a json error when the parameters are empty" do
        get "/api/v1/items/find_all?name="

        expect(response.status).to eq(404)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end
    end
  end
end