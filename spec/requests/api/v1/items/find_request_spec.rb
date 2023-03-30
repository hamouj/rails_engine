#frozen_string_literal: true

require "rails_helper"

describe "Items/Find API" do
  describe "happy path testing" do
    describe "name match" do
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

    describe "min and max price match" do
      before(:each) do
        @item1 = create(:item, unit_price: 32.45)
        @item2 = create(:item, unit_price: 14.75)
        @item3 = create(:item, unit_price: 4.44)
      end

      it "returns all items by minimum price" do
        get "/api/v1/items/find_all?min_price=13.24"

        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(response_body.count).to eq(2)
        expect(response_body).to be_an Array

        expect(response_body[0]).to have_key :id
        expect(response_body[0][:id]).to eq(@item2.id.to_s)
        
        expect(response_body[0][:attributes]).to have_key :name
        expect(response_body[0][:attributes][:name]).to eq(@item2.name)

        expect(response_body[1]).to have_key :id
        expect(response_body[1][:id]).to eq(@item1.id.to_s)
        
        expect(response_body[1][:attributes]).to have_key :name
        expect(response_body[1][:attributes][:name]).to eq(@item1.name)
      end

      it "returns all items by maximum price" do
        get "/api/v1/items/find_all?max_price=15.24"

        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(response_body.count).to eq(2)
        expect(response_body).to be_an Array

        expect(response_body[0]).to have_key :id
        expect(response_body[0][:id]).to eq(@item3.id.to_s)
        
        expect(response_body[0][:attributes]).to have_key :name
        expect(response_body[0][:attributes][:name]).to eq(@item3.name)

        expect(response_body[1]).to have_key :id
        expect(response_body[1][:id]).to eq(@item2.id.to_s)
        
        expect(response_body[1][:attributes]).to have_key :name
        expect(response_body[1][:attributes][:name]).to eq(@item2.name)
      end

      it "returns all items by maximum and minimum price" do
        get "/api/v1/items/find_all?min_price=13.24&max_price=34"

        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(response_body.count).to eq(2)
        expect(response_body).to be_an Array

        expect(response_body[0]).to have_key :id
        expect(response_body[0][:id]).to eq(@item2.id.to_s)
        
        expect(response_body[0][:attributes]).to have_key :name
        expect(response_body[0][:attributes][:name]).to eq(@item2.name)

        expect(response_body[1]).to have_key :id
        expect(response_body[1][:id]).to eq(@item1.id.to_s)
        
        expect(response_body[1][:attributes]).to have_key :name
        expect(response_body[1][:attributes][:name]).to eq(@item1.name)
      end
    end
  end

  describe "sad path testing" do
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

    describe "find all items by minimum price" do
      it "returns an empty array when there is no match" do
        create(:item, unit_price: 19.87)
        create(:item, unit_price: 35.69)
        create(:item, unit_price: 3)

        get "/api/v1/items/find_all?min_price=60"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to be_an Array
        expect(response_body[:data].count).to eq(0)
      end

      it "returns a single item within an array when there is only on match" do
        item = create(:item, unit_price: 3.78)

        get "/api/v1/items/find_all?min_price=3"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to be_an Array
        expect(response_body[:data].count).to eq(1)
      end
    end

    describe "find all items by maximum price" do
      it "returns an empty array when there is no match" do
        create(:item, unit_price: 19.87)
        create(:item, unit_price: 35.69)
        create(:item, unit_price: 3)

        get "/api/v1/items/find_all?max_price=1"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to be_an Array
        expect(response_body[:data].count).to eq(0)
      end

      it "returns a single item within an array when there is only on match" do
        item = create(:item, unit_price: 3.78)

        get "/api/v1/items/find_all?max_price=4"
          
        expect(response).to be_successful

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :data
        expect(response_body[:data]).to be_an Array
        expect(response_body[:data].count).to eq(1)
      end
    end
  end

  describe "edge case testing" do
    describe "find all items by name" do
      it "returns a json error when the parameters are missing" do
        get "/api/v1/items/find_all"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end

      it "returns a json error when the parameters are empty" do
        get "/api/v1/items/find_all?name="

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end
    end

    describe "find all items by minimum price" do
      it "returns a json error when the parameters are missing" do
        get "/api/v1/items/find_all"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end

      it "returns a json error when the parameters are empty" do
        get "/api/v1/items/find_all?min_price="

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end

      it "returns a json error when the parameters are negative numbers" do
        get "/api/v1/items/find_all?min_price=-34"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end

      it "returns a json error when the parameters given include letters" do
        get "/api/v1/items/find_all?min_price=3Ak5"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end

      it "returns a json error when name and min_price parameters are given" do
        get "/api/v1/items/find_all?name=fin&min_price=35.2"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end
    end

    describe "find all items by maximum price" do
      it "returns a json error when the parameters are missing" do
        get "/api/v1/items/find_all"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end

      it "returns a json error when the parameters are empty" do
        get "/api/v1/items/find_all?max_price="

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end

      it "returns a json error when the parameters are negative numbers" do
        get "/api/v1/items/find_all?max_price=-34"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end

      it "returns a json error when the paramters given include letters" do
        get "/api/v1/items/find_all?max_price=3Ak5"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end

      it "returns a json error when name and max_price parameters are given" do
        get "/api/v1/items/find_all?name=fin&max_price=35"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter is incorrect")
      end
    end
  end
end