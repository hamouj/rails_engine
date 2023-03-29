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
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: :created
    else
      render json: ErrorSerializer.item_serialized_json(item.errors), status: 404
    end
  end

  def update
    begin
      item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      if item.update(item_params)
        render json: ItemSerializer.new(item)
      else
        render json: ErrorSerializer.item_serialized_json(item.errors), status: 404
      end
    end
  end

  def destroy
    begin
      item = Item.find(params[:id])
    rescue ActiveRecord::RecordNotFound => error
      render json: ErrorSerializer.serialized_json(error), status: 404
    else
      item.find_single_item_invoices.destroy_all
      item.destroy
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end