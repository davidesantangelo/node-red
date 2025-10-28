# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Node
  module Red
    class Client
      attr_reader :base_url, :access_token

      # Initialize a new Node-RED Admin API client
      #
      # @param base_url [String] The base URL of the Node-RED instance (e.g., "http://localhost:1880")
      # @param access_token [String, nil] Optional access token for authentication
      def initialize(base_url, access_token: nil)
        @base_url = base_url.chomp("/")
        @access_token = access_token
      end

      # ==================== Authentication Methods ====================

      # Get the active authentication scheme
      #
      # @return [Hash] Authentication scheme information
      def auth_login
        get("/auth/login")
      end

      # Exchange credentials for access token
      #
      # @param client_id [String] The client ID
      # @param grant_type [String] The grant type (e.g., "password")
      # @param scope [String] The scope (e.g., "*" for full access)
      # @param username [String] The username
      # @param password [String] The password
      # @return [Hash] Token response with access_token
      def auth_token(client_id:, grant_type:, scope:, username:, password:)
        body = {
          client_id: client_id,
          grant_type: grant_type,
          scope: scope,
          username: username,
          password: password
        }
        response = post("/auth/token", body, use_auth: false)
        @access_token = response["access_token"] if response["access_token"]
        response
      end

      # Revoke an access token
      #
      # @param token [String] The token to revoke
      # @return [Hash] Revocation response
      def auth_revoke(token)
        body = { token: token }
        post("/auth/revoke", body)
      end

      # ==================== Settings & Diagnostics ====================

      # Get the runtime settings
      #
      # @return [Hash] Runtime settings
      def settings
        get("/settings")
      end

      # Get the runtime diagnostics
      #
      # @return [Hash] Runtime diagnostics
      def diagnostics
        get("/diagnostics")
      end

      # ==================== Flow Management ====================

      # Get the active flow configuration
      #
      # @return [Array<Hash>] Array of flow configurations
      def flows
        get("/flows")
      end

      # Get the active flow's runtime state
      #
      # @return [Hash] Flow runtime state
      def flows_state
        get("/flows/state")
      end

      # Set the active flow configuration
      #
      # @param flows [Array<Hash>] The flow configuration
      # @param rev [String, nil] Optional revision identifier
      # @return [Hash] Response with revision ID
      def deploy_flows(flows, rev: nil)
        body = { flows: flows }
        body[:rev] = rev if rev
        post("/flows", body)
      end

      # Set the active flow's runtime state
      #
      # @param state [String] The desired state ("start" or "stop")
      # @return [Hash] State change response
      def set_flows_state(state)
        body = { state: state }
        post("/flows/state", body)
      end

      # Add a flow to the active configuration
      #
      # @param flow [Hash] The flow configuration
      # @return [Hash] The created flow with ID
      def add_flow(flow)
        post("/flow", flow)
      end

      # Get an individual flow configuration
      #
      # @param id [String] The flow ID
      # @return [Hash] Flow configuration
      def flow(id)
        get("/flow/#{id}")
      end

      # Update an individual flow configuration
      #
      # @param id [String] The flow ID
      # @param flow [Hash] The updated flow configuration
      # @return [Hash] The updated flow
      def update_flow(id, flow)
        put("/flow/#{id}", flow)
      end

      # Delete an individual flow configuration
      #
      # @param id [String] The flow ID
      # @return [Hash] Deletion response
      def delete_flow(id)
        delete("/flow/#{id}")
      end

      # ==================== Node Management ====================

      # Get a list of the installed nodes
      #
      # @return [Array<Hash>] List of installed nodes
      def nodes
        get("/nodes")
      end

      # Install a new node module
      #
      # @param module_name [String] The name of the node module to install
      # @return [Hash] Installation response
      def install_node(module_name)
        body = { module: module_name }
        post("/nodes", body)
      end

      # Get a node module's information
      #
      # @param module_name [String] The module name
      # @return [Hash] Module information
      def node_module(module_name)
        get("/nodes/#{module_name}")
      end

      # Enable or disable a node module
      #
      # @param module_name [String] The module name
      # @param enabled [Boolean] Whether to enable or disable the module
      # @return [Hash] Update response
      def update_node_module(module_name, enabled:)
        body = { enabled: enabled }
        put("/nodes/#{module_name}", body)
      end

      # Remove a node module
      #
      # @param module_name [String] The module name
      # @return [Hash] Deletion response
      def delete_node_module(module_name)
        delete("/nodes/#{module_name}")
      end

      # Get a node module set information
      #
      # @param module_name [String] The module name
      # @param set_name [String] The set name
      # @return [Hash] Node set information
      def node_set(module_name, set_name)
        get("/nodes/#{module_name}/#{set_name}")
      end

      # Enable or disable a node set
      #
      # @param module_name [String] The module name
      # @param set_name [String] The set name
      # @param enabled [Boolean] Whether to enable or disable the set
      # @return [Hash] Update response
      def update_node_set(module_name, set_name, enabled:)
        body = { enabled: enabled }
        put("/nodes/#{module_name}/#{set_name}", body)
      end

      private

      # Perform a GET request
      #
      # @param path [String] The API path
      # @return [Hash, Array] Parsed JSON response
      def get(path)
        request(:get, path)
      end

      # Perform a POST request
      #
      # @param path [String] The API path
      # @param body [Hash] The request body
      # @param use_auth [Boolean] Whether to use authentication
      # @return [Hash] Parsed JSON response
      def post(path, body, use_auth: true)
        request(:post, path, body: body, use_auth: use_auth)
      end

      # Perform a PUT request
      #
      # @param path [String] The API path
      # @param body [Hash] The request body
      # @return [Hash] Parsed JSON response
      def put(path, body)
        request(:put, path, body: body)
      end

      # Perform a DELETE request
      #
      # @param path [String] The API path
      # @return [Hash] Parsed JSON response
      def delete(path)
        request(:delete, path)
      end

      # Perform an HTTP request
      #
      # @param method [Symbol] HTTP method (:get, :post, :put, :delete)
      # @param path [String] The API path
      # @param body [Hash, nil] Optional request body
      # @param use_auth [Boolean] Whether to use authentication
      # @return [Hash, Array] Parsed JSON response
      def request(method, path, body: nil, use_auth: true)
        uri = URI.join(@base_url, path)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"

        request = case method
                  when :get
                    Net::HTTP::Get.new(uri)
                  when :post
                    Net::HTTP::Post.new(uri)
                  when :put
                    Net::HTTP::Put.new(uri)
                  when :delete
                    Net::HTTP::Delete.new(uri)
                  else
                    raise ArgumentError, "Unsupported HTTP method: #{method}"
                  end

        request["Content-Type"] = "application/json"
        request["Accept"] = "application/json"
        request["Authorization"] = "Bearer #{@access_token}" if use_auth && @access_token

        request.body = body.to_json if body

        response = http.request(request)
        handle_response(response)
      end

      # Handle the HTTP response
      #
      # @param response [Net::HTTPResponse] The HTTP response
      # @return [Hash, Array] Parsed JSON response
      # @raise [ApiError, AuthenticationError, NotFoundError, ServerError] Various error types
      def handle_response(response)
        case response
        when Net::HTTPSuccess
          parse_response_body(response)
        when Net::HTTPBadRequest
          raise_api_error(BadRequestError, response)
        when Net::HTTPUnauthorized
          raise_api_error(AuthenticationError, response)
        when Net::HTTPNotFound
          raise_api_error(NotFoundError, response)
        when Net::HTTPConflict
          raise_api_error(ConflictError, response)
        when Net::HTTPClientError
          raise_api_error(ApiError, response)
        when Net::HTTPServerError
          raise_api_error(ServerError, response)
        else
          raise_api_error(UnexpectedResponseError, response)
        end
      end

      # Parse a successful HTTP response body, ensuring JSON content
      #
      # @param response [Net::HTTPResponse] The HTTP response
      # @return [Hash, Array] Parsed JSON response or empty hash for blank body
      def parse_response_body(response)
        body = response.body
        return {} if body.nil? || body.strip.empty?

        JSON.parse(body)
      rescue JSON::ParserError => e
        raise UnexpectedResponseError.new(
          "Invalid JSON response: #{e.message}",
          status: response.code.to_i,
          details: { body: body }
        )
      end

      # Raise a structured API error based on the HTTP response
      #
      # @param error_class [Class<ApiError>] The error class to raise
      # @param response [Net::HTTPResponse] The HTTP response
      # @raise [ApiError]
      def raise_api_error(error_class, response)
        message, error_code, details = extract_error_details(response)
        raise error_class.new(
          message,
          status: response.code.to_i,
          code: error_code,
          details: details
        )
      end

      # Extract error details from a failed HTTP response
      #
      # @param response [Net::HTTPResponse] The HTTP response
      # @return [Array(String, String, Hash, nil)] message, error code and raw details
      def extract_error_details(response)
        body = response.body
        return [response.message, nil, nil] if body.nil? || body.strip.empty?

        data = JSON.parse(body)
        message = data["message"] || data["error"] || response.message
        error_code = data["code"]
        [message, error_code, data]
      rescue JSON::ParserError
        [response.message, nil, { raw_body: body }]
      end
    end
  end
end
