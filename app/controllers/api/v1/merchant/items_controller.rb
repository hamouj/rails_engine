# frozen_string_literal: true

# ./app/controllers/api/v1/merchant/items_controller
class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: ItemSerializer.new(merchant.items)
  end
end
