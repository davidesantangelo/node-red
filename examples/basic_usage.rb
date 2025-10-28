# frozen_string_literal: true

# Example usage of the Node-RED Admin API Ruby client
#
# Make sure you have a Node-RED instance running at http://localhost:1880
# before running this example.

require "node/red"

# Initialize the client
client = Node::Red::Client.new("http://localhost:1880")

begin
  # Example 1: Get runtime settings
  puts "=== Runtime Settings ==="
  settings = client.settings
  puts "HTTP Node Root: #{settings["httpNodeRoot"]}"
  puts "Version: #{settings["version"]}"
  puts

  # Example 2: Get all flows
  puts "=== Current Flows ==="
  flows = client.flows
  puts "Total flows: #{flows.length}"
  flows.each do |flow|
    puts "  - Flow: #{flow["label"]} (#{flow["id"]})" if flow["type"] == "tab"
  end
  puts

  # Example 3: Get all installed nodes
  puts "=== Installed Nodes ==="
  nodes = client.nodes
  puts "Total node modules: #{nodes.length}"
  nodes.take(5).each do |node|
    puts "  - #{node["id"]} (v#{node["version"]})"
  end
  puts

  # Example 4: Get flow runtime state
  puts "=== Flow Runtime State ==="
  state = client.flows_state
  puts "State: #{state["state"]}"
  puts

  # Example 5: Get diagnostics (if available)
  puts "=== Diagnostics ==="
  begin
    diagnostics = client.diagnostics
    puts "Node.js version: #{diagnostics["nodejs"]}"
    puts "OS: #{diagnostics["os"]}"
  rescue Node::Red::NotFoundError
    puts "Diagnostics endpoint not available (requires Node-RED 1.1.0+)"
  end
  puts

  # Example with authentication (uncomment to use)
  # puts "=== Authentication Example ==="
  # token_response = client.auth_token(
  #   client_id: "node-red-admin",
  #   grant_type: "password",
  #   scope: "*",
  #   username: "admin",
  #   password: "password"
  # )
  # puts "Access token obtained: #{token_response['access_token'][0..20]}..."
rescue Node::Red::AuthenticationError => e
  puts "Authentication required: #{e.message}"
rescue Node::Red::NotFoundError => e
  puts "Resource not found: #{e.message}"
rescue Node::Red::ServerError => e
  puts "Server error: #{e.message}"
rescue Node::Red::ApiError => e
  puts "API error: #{e.message}"
rescue Errno::ECONNREFUSED
  puts "Error: Could not connect to Node-RED at http://localhost:1880"
  puts "Make sure Node-RED is running before executing this example."
end
