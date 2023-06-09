# frozen_string_literal: true

# ./app/controllers/api/v1/merchants/find_controller
class Api::V1::Merchants::FindController < ApplicationController
  def show
    if !params[:name].present?
      render json: ErrorSerializer.missing_parameter, status: 400
    elsif Merchant.find_by_name(params[:name]).nil?
      render json: ErrorSerializer.undefined_error, status: 200
    else
      render json: MerchantSerializer.new(Merchant.find_by_name(params[:name]))
    end
  end
end