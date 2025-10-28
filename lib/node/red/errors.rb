# frozen_string_literal: true

module Node
  module Red
    # Base error class for Node-RED API errors that keeps rich context
    class ApiError < StandardError
      attr_reader :status, :code, :details

      def initialize(message, status:, code: nil, details: nil)
        super(message)
        @status = status
        @code = code
        @details = details
      end
    end

    # Raised when the request is malformed (HTTP 400)
    class BadRequestError < ApiError; end

    # Raised when authentication fails (HTTP 401)
    class AuthenticationError < ApiError; end

    # Raised when a resource is not found (HTTP 404)
    class NotFoundError < ApiError; end

    # Raised when there is a version mismatch (HTTP 409)
    class ConflictError < ApiError; end

    # Raised when the server returns a 5xx error
    class ServerError < ApiError; end

    # Raised when the response type is unexpected
    class UnexpectedResponseError < ApiError; end
  end
end
