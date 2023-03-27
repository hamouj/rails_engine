# frozen_string_literal: true

# ./app/serializers/merchant_serializer
class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name
end
