# frozen_string_literal: true

# Example: Managing nodes with Node-RED Admin API
#
# This example demonstrates installing, updating, and removing node modules

require "node/red"

# Initialize the client
client = Node::Red::Client.new("http://localhost:1880")

begin
  # List all installed nodes
  puts "=== Installed Node Modules ==="
  nodes = client.nodes

  # Group by module
  modules = nodes.group_by { |n| n["module"] }.keys.compact
  puts "Total modules installed: #{modules.length}"
  puts

  # Show first 10 modules
  puts "Sample of installed modules:"
  modules.take(10).each do |module_name|
    puts "  - #{module_name}"
  end
  puts

  # Get information about a specific module
  puts "=== Node-RED Core Module Info ==="
  begin
    core_module = client.node_module("node-red")
    puts "Module: #{core_module["name"]}"
    puts "Version: #{core_module["version"]}"
    puts "Nodes in module: #{core_module["nodes"]&.length || 0}"
  rescue Node::Red::NotFoundError
    puts "Core module information not available"
  end
  puts

  # Install a node module (commented out for safety)
  puts "=== Installing a Node Module ==="
  puts "Example (commented out for safety):"
  puts "  client.install_node('node-red-contrib-example')"
  puts
  # Uncomment to actually install:
  # begin
  #   result = client.install_node('node-red-contrib-example')
  #   puts "Module installed: #{result['name']}"
  # rescue Node::Red::ApiError => e
  #   puts "Installation failed: #{e.message}"
  # end

  # Get node set information
  puts "=== Node Set Information ==="
  begin
    # Example: Get info about the inject node set
    node_set = client.node_set("node-red", "common")
    puts "Node set: #{node_set["id"]}"
    puts "Enabled: #{node_set["enabled"]}"
    puts "Types: #{node_set["types"]&.join(", ")}"
  rescue Node::Red::NotFoundError
    puts "Node set not found"
  end
  puts

  # Enable/Disable a node module (commented out for safety)
  puts "=== Enable/Disable Node Module ==="
  puts "Example (commented out for safety):"
  puts "  # Disable a module"
  puts "  client.update_node_module('node-red-contrib-example', enabled: false)"
  puts
  puts "  # Enable a module"
  puts "  client.update_node_module('node-red-contrib-example', enabled: true)"
  puts

  # Enable/Disable a node set (commented out for safety)
  puts "=== Enable/Disable Node Set ==="
  puts "Example (commented out for safety):"
  puts "  # Disable a node set"
  puts "  client.update_node_set('node-red', 'common', enabled: false)"
  puts
  puts "  # Enable a node set"
  puts "  client.update_node_set('node-red', 'common', enabled: true)"
  puts

  # Remove a node module (commented out for safety)
  puts "=== Removing a Node Module ==="
  puts "Example (commented out for safety):"
  puts "  client.delete_node_module('node-red-contrib-example')"
  puts

  puts "Example completed successfully!"
  puts
  puts "Note: Dangerous operations (install/delete/enable/disable) are commented out"
  puts "for safety. Uncomment them in the source code to test these features."
rescue Node::Red::AuthenticationError => e
  puts "Authentication required: #{e.message}"
rescue Node::Red::ApiError => e
  puts "API Error: #{e.message}"
rescue Errno::ECONNREFUSED
  puts "Error: Could not connect to Node-RED at http://localhost:1880"
  puts "Make sure Node-RED is running before executing this example."
end
