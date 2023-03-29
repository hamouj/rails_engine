# frozen_string_literal: true

# ./app/controllers/api/v1/merchants/find_controller
class Api::V1::Merchants::FindController < ApplicationController
  def show
    merchant = Merchant.find_by_name(params[:name])

    if merchant.nil?
      render json: ErrorSerializer.undefined_error, status: 200
    else
      render json: MerchantSerializer.new(merchant)
    end
  end
end