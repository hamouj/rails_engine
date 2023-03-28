# frozen_string_literal: true

# ./app/serializers/item_serializer
class ItemSerializer
  include JSONAPI::Serializer
  attributes :name, :description, :unit_price, :merchant_id
end
