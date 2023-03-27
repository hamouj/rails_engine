# frozen_string_literal: true

# ./app/controllers/api/v1/merchants_controller
class Api::V1::MerchantsController < ApplicationController
  def index
    render json: Merchant.all
  end
end