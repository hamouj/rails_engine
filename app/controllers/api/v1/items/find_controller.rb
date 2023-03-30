# frozen_string_literal: true

# ./app/controllers/api/v1/items/find_controller
class Api::V1::Items::FindController < ApplicationController
  before_action :numericality_check
  before_action :integer_check
  before_action :name_and_price_check
  
  def index
    if params[:min_price].present? && params[:max_price].present?
      min_max_price
    elsif params[:min_price].present? && !params[:max_price].present?
      min_price
    elsif params[:max_price].present? && !params[:min_price].present?
      max_price
    elsif params[:name].present?
      name
    else
      render json: ErrorSerializer.missing_parameter, status: 400
    end
  end

  private

  def numericality_check
    if params[:min_price].to_f < 0 || params[:max_price].to_f < 0
      render json: ErrorSerializer.incorrect_parameter, status: 400
    end
  end

  def integer_check
    if (params[:min_price] && numeric?(params[:min_price]) == false) || (params[:max_price] && numeric?(params[:max_price]) == false)
      render json: ErrorSerializer.incorrect_parameter, status: 400
    end
  end

  def name_and_price_check
    if (params[:min_price].present? && params[:name]) || (params[:max_price].present? && params[:name])
      render json: ErrorSerializer.incorrect_parameter, status: 400
    end
  end

  def name
    render json: ItemSerializer.new(Item.find_by_name(params[:name]))
  end

  def min_price
    render json: ItemSerializer.new(Item.find_by_min_price(params[:min_price]))
  end

  def max_price
    render json: ItemSerializer.new(Item.find_by_max_price(params[:max_price]))
  end

  def min_max_price
    render json: ItemSerializer.new(Item.find_by_min_max_price(params[:min_price], params[:max_price]))
  end

  def numeric?(string)
    Float(string) != nil rescue false
  end
end
