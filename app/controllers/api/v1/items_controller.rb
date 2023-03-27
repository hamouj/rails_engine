# frozen_string_literal: true

# ./app/controllers/api/v1/items_controller
class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end
end