# frozen_string_literal: true

# Example: Managing flows with Node-RED Admin API
#
# This example demonstrates creating, updating, and deleting flows

require "node/red"

# Initialize the client
client = Node::Red::Client.new("http://localhost:1880")

begin
  # Get current flows
  puts "=== Getting Current Flows ==="
  current_flows = client.flows
  puts "Current number of flows: #{current_flows.length}"
  puts

  # Add a new flow
  puts "=== Adding a New Flow ==="
  new_flow = {
    label: "Example Flow",
    type: "tab",
    disabled: false,
    info: "This is an example flow created via the API"
  }

  created_flow = client.add_flow(new_flow)
  flow_id = created_flow["id"]
  puts "Created flow with ID: #{flow_id}"
  puts "Flow label: #{created_flow["label"]}"
  puts

  # Get the specific flow
  puts "=== Getting Specific Flow ==="
  flow_details = client.flow(flow_id)
  puts "Flow: #{flow_details["label"]}"
  puts "Type: #{flow_details["type"]}"
  puts

  # Update the flow
  puts "=== Updating Flow ==="
  updated_flow = {
    id: flow_id,
    label: "Updated Example Flow",
    type: "tab",
    disabled: false,
    info: "This flow has been updated"
  }

  result = client.update_flow(flow_id, updated_flow)
  puts "Flow updated: #{result["label"]}"
  puts

  # Example: Deploy flows with nodes
  puts "=== Deploying Complete Flow Configuration ==="

  # Create a simple flow with an inject and debug node

  # NOTE: Be careful with deploy_flows as it replaces ALL flows
  # Uncomment the following lines to deploy
  # deployment = client.deploy_flows(complete_flows)
  # puts "Flows deployed with revision: #{deployment['rev']}"
  puts "Flow deployment commented out for safety"
  puts

  # Check flow state
  puts "=== Flow Runtime State ==="
  state = client.flows_state
  puts "Current state: #{state["state"]}"
  puts

  # Stop flows (uncomment to use)
  # puts "=== Stopping Flows ==="
  # client.set_flows_state('stop')
  # puts "Flows stopped"
  #
  # sleep 2
  #
  # puts "=== Starting Flows ==="
  # client.set_flows_state('start')
  # puts "Flows started"
  # puts

  # Clean up - delete the flow we created
  puts "=== Deleting Flow ==="
  client.delete_flow(flow_id)
  puts "Flow #{flow_id} deleted"
  puts

  puts "Example completed successfully!"
rescue Node::Red::NotFoundError => e
  puts "Error: #{e.message}"
rescue Node::Red::ApiError => e
  puts "API Error: #{e.message}"
rescue Errno::ECONNREFUSED
  puts "Error: Could not connect to Node-RED at http://localhost:1880"
  puts "Make sure Node-RED is running before executing this example."
end
