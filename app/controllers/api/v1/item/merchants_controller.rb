# frozen_string_literal: true

# ./app/controllers/api/v1/item/merchants_controller.rb
class Api::V1::Item::MerchantsController < ApplicationController
  def show
    item = Item.find(params[:item_id])
    render json: MerchantSerializer.new(item.merchant)
  end
end
