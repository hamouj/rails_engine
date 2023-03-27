# frozen_string_literal: true

# ./app/controllers/api/v1/merchant/items_controller
class Api::V1::Merchant::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.for_merchant(params[:merchant_id]))
  end
end