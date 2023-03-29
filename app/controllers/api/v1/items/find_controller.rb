# frozen_string_literal: true

# ./app/controllers/api/v1/items/find_controller
class Api::V1::Items::FindController < ApplicationController
  def index
    if !params[:name].present?
      render json: ErrorSerializer.missing_parameter, status: 404
    elsif Item.find_by_name(params[:name]).nil?
      render json: ErrorSerializer.undefined_error, status: 200
    else
      render json: ItemSerializer.new(Item.find_by_name(params[:name]))
    end
  end
end