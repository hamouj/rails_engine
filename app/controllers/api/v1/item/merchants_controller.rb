# frozen_string_literal: true

# ./app/controllers/api/v1/item/merchants_controller.rb
class Api::V1::Item::MerchantsController < ApplicationController
  def index
    merchant = Item.find(params[:item_id]).merchant
    render json: MerchantSerializer.new(merchant)
  end
end