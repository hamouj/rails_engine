# frozen_string_literal: true

# ./app/controllers/api/v1/items_controller
class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    begin
      item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      render json: ItemSerializer.new(item)
    end
  end

  def create
    item = Item.create(item_params)
    render json: ItemSerializer.new(item), status: :created
  end

  def update
    item = Item.find(params[:id])
    item.update(item_params)
    render json: ItemSerializer.new(item)
  end

  def destroy
    begin
      item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      item.find_single_item_invoices.destroy_all
      render json: item.destroy, status: 204
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end