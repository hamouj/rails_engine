# frozen_string_literal: true

# ./app/serializers/error_serializer
class ErrorSerializer
  def self.serialized_json(error)
    {
      "message": "your query could not be completed",
      "errors": [
        "#{error.message}"
      ]
    }
  end

  def self.validation_serialized_json(error)
    {
      "message": "your query could not be completed",
      "errors":
        error.message.split(',').map do |message|
          message.strip
        end 
    }
  end

  def self.undefined_error
    {
      "data": {}
    }
  end

  def self.missing_parameter
    {
      "message": "your query could not be completed",
        "errors": [
          "parameter cannot be missing"
        ]
    }
  end

  def self.incorrect_parameter
    {
      "message": "your query could not be completed",
        "errors": [
          "parameter is incorrect"
        ]
    }
  end
end
