class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :error_response
  rescue_from ActiveRecord::RecordInvalid, with: :validation_error_response

  def error_response(error)
    render json: ErrorSerializer.serialized_json(error), status: 404
  end

  def validation_error_response(error)
    render json: ErrorSerializer.validation_serialized_json(error), status: 400
  end
end
