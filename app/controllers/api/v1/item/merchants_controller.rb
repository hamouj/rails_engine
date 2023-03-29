# frozen_string_literal: true

# ./app/controllers/api/v1/item/merchants_controller.rb
class Api::V1::Item::MerchantsController < ApplicationController
  def show
    begin
      merchant = Item.find(params[:item_id]).merchant
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      render json: MerchantSerializer.new(merchant)
    end
  end
end