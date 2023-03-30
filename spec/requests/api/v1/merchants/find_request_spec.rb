#frozen_string_literal: true

require "rails_helper"

describe "Merchants/Find API" do
  describe "happy path testing" do
    describe "partial name match" do
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
  end

  describe "edge case testing" do
    describe "find one merchant by name" do
      it "returns a json error when the parameters are missing" do
        get "/api/v1/merchants/find"

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end

      it "returns a json error when the parameters are empty" do
        get "/api/v1/merchants/find?name="

        expect(response.status).to eq(400)

        response_body = JSON.parse(response.body, symbolize_names: true)

        expect(response_body).to have_key :message
        expect(response_body[:message]).to eq("your query could not be completed")
        
        expect(response_body).to have_key :errors
        expect(response_body[:errors].first).to eq("parameter cannot be missing")
      end
    end
  end
end
