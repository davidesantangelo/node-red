# Node::Red

A Ruby client library for the [Node-RED Admin HTTP API](https://nodered.org/docs/api/admin/). This gem provides a comprehensive wrapper around the Node-RED Admin API, allowing you to programmatically manage flows, nodes, settings, and authentication.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add node-red
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install node-red
```

## Usage

### Basic Setup

```ruby
require 'node/red'

# Create a client instance
client = Node::Red::Client.new('http://localhost:1880')

# Or with authentication
client = Node::Red::Client.new('http://localhost:1880', access_token: 'your-access-token')
```

### Authentication

```ruby
# Get authentication scheme
auth_info = client.auth_login

# Exchange credentials for access token
token_response = client.auth_token(
  client_id: 'node-red-admin',
  grant_type: 'password',
  scope: '*',
  username: 'admin',
  password: 'password'
)

# The access token is automatically set on the client
puts client.access_token

# Revoke a token
client.auth_revoke(token_response['access_token'])
```

### Settings & Diagnostics

```ruby
# Get runtime settings
settings = client.settings
puts settings['httpNodeRoot']

# Get runtime diagnostics
diagnostics = client.diagnostics
```

### Flow Management

```ruby
# Get all flows
flows = client.flows

# Deploy new flows
new_flows = [
  { id: 'tab1', type: 'tab', label: 'Flow 1' },
  { id: 'node1', type: 'inject', z: 'tab1', name: 'test' }
]
response = client.deploy_flows(new_flows)

# Get flow runtime state
state = client.flows_state

# Set flow runtime state
client.set_flows_state('stop')  # or 'start'

# Add a single flow
new_flow = { label: 'New Flow', type: 'tab' }
created_flow = client.add_flow(new_flow)

# Get a specific flow
flow = client.flow('flow-id')

# Update a flow
updated_flow = client.update_flow('flow-id', { label: 'Updated Flow', type: 'tab' })

# Delete a flow
client.delete_flow('flow-id')
```

### Node Management

```ruby
# Get all installed nodes
nodes = client.nodes

# Install a new node module
client.install_node('node-red-contrib-example')

# Get node module information
module_info = client.node_module('node-red-contrib-example')

# Enable/disable a node module
client.update_node_module('node-red-contrib-example', enabled: false)
client.update_node_module('node-red-contrib-example', enabled: true)

# Remove a node module
client.delete_node_module('node-red-contrib-example')

# Get node set information
set_info = client.node_set('node-red', 'core')

# Enable/disable a node set
client.update_node_set('node-red', 'core', enabled: true)
```

### Error Handling

The library provides specific error classes for different error scenarios:

```ruby
begin
  client.flow('non-existent-id')
rescue Node::Red::NotFoundError => e
  puts "Flow not found: #{e.message}"
rescue Node::Red::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Node::Red::ServerError => e
  puts "Server error: #{e.message}"
rescue Node::Red::ApiError => e
  puts "API error: #{e.message}"
end
```

Each error object carries contextual information to help with debugging:

```ruby
rescue Node::Red::ApiError => e
  puts e.status   # => 400, 401, 404, 409, 500, ...
  puts e.code     # => "invalid_request", "module_already_loaded", ... (may be nil)
  puts e.details  # => full parsed response body, if available
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidesantangelo/node-red. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/davidesantangelo/node-red/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Node::Red project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davidesantangelo/node-red/blob/master/CODE_OF_CONDUCT.md).
