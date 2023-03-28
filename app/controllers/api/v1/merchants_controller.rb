# frozen_string_literal: true

# ./app/controllers/api/v1/merchants_controller
class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    begin
      Merchant.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    end
  end
end