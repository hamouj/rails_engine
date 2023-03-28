# frozen_string_literal: true

# ./app/controllers/api/v1/merchant/items_controller
class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    begin
      Merchant.find(params[:merchant_id])
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      render json: ItemSerializer.new(Item.for_merchant(params[:merchant_id]))
    end
  end
end