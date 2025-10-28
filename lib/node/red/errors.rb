# frozen_string_literal: true

module Node
  module Red
    # Base error class for Node-RED API errors
    class ApiError < StandardError; end

    # Raised when authentication fails
    class AuthenticationError < ApiError; end

    # Raised when a resource is not found
    class NotFoundError < ApiError; end

    # Raised when the server returns a 5xx error
    class ServerError < ApiError; end
  end
end
