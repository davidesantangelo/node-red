# frozen_string_literal: true

RSpec.describe Node::Red::Client do
  let(:base_url) { "http://localhost:1880" }
  let(:client) { described_class.new(base_url) }
  let(:json_headers) { { "Content-Type" => "application/json" } }

  describe "#initialize" do
    it "sets the base URL" do
      expect(client.base_url).to eq(base_url)
    end

    it "strips trailing slash from base URL" do
      client_with_slash = described_class.new("http://localhost:1880/")
      expect(client_with_slash.base_url).to eq(base_url)
    end

    it "sets the access token when provided" do
      authenticated_client = described_class.new(base_url, access_token: "test-token")
      expect(authenticated_client.access_token).to eq("test-token")
    end

    it "has nil access token when not provided" do
      expect(client.access_token).to be_nil
    end
  end

  describe "authentication endpoints" do
    it "fetches auth scheme" do
      stub_request(:get, "#{base_url}/auth/login")
        .to_return(status: 200, body: { type: "credentials" }.to_json, headers: json_headers)

      expect(client.auth_login).to eq("type" => "credentials")
    end

    it "exchanges credentials for token and stores it" do
      stub_request(:post, "#{base_url}/auth/token")
        .with(body: {
          client_id: "node-red-admin",
          grant_type: "password",
          scope: "*",
          username: "admin",
          password: "secret"
        }.to_json)
        .to_return(status: 200, body: { access_token: "abc123" }.to_json, headers: json_headers)

      response = client.auth_token(
        client_id: "node-red-admin",
        grant_type: "password",
        scope: "*",
        username: "admin",
        password: "secret"
      )

      expect(response).to eq("access_token" => "abc123")
      expect(client.access_token).to eq("abc123")
    end

    it "revokes a token" do
      stub_request(:post, "#{base_url}/auth/revoke")
        .with(body: { token: "abc123" }.to_json)
        .to_return(status: 200, body: { revoked: true }.to_json, headers: json_headers)

      expect(client.auth_revoke("abc123")).to eq("revoked" => true)
    end
  end

  describe "settings and diagnostics" do
    it "fetches settings" do
      stub_request(:get, "#{base_url}/settings")
        .to_return(status: 200, body: { httpNodeRoot: "/" }.to_json, headers: json_headers)

      expect(client.settings).to eq("httpNodeRoot" => "/")
    end

    it "fetches diagnostics" do
      stub_request(:get, "#{base_url}/diagnostics")
        .to_return(status: 200, body: { os: "darwin" }.to_json, headers: json_headers)

      expect(client.diagnostics).to eq("os" => "darwin")
    end
  end

  describe "flow management" do
    it "lists flows" do
      stub_request(:get, "#{base_url}/flows")
        .to_return(status: 200, body: [{ id: "tab1" }].to_json, headers: json_headers)

      expect(client.flows).to eq([{ "id" => "tab1" }])
    end

    it "gets flow state" do
      stub_request(:get, "#{base_url}/flows/state")
        .to_return(status: 200, body: { state: "running" }.to_json, headers: json_headers)

      expect(client.flows_state).to eq("state" => "running")
    end

    it "deploys flows with optional revision" do
      stub_request(:post, "#{base_url}/flows")
        .with(body: { flows: [{ id: "tab1" }], rev: "123" }.to_json)
        .to_return(status: 200, body: { rev: "124" }.to_json, headers: json_headers)

      response = client.deploy_flows([{ id: "tab1" }], rev: "123")
      expect(response).to eq("rev" => "124")
    end

    it "sets flow runtime state" do
      stub_request(:post, "#{base_url}/flows/state")
        .with(body: { state: "stop" }.to_json)
        .to_return(status: 200, body: { state: "stopped" }.to_json, headers: json_headers)

      expect(client.set_flows_state("stop")).to eq("state" => "stopped")
    end

    it "adds a flow" do
      stub_request(:post, "#{base_url}/flow")
        .with(body: { label: "New Flow" }.to_json)
        .to_return(status: 200, body: { id: "flow1" }.to_json, headers: json_headers)

      expect(client.add_flow({ label: "New Flow" })).to eq("id" => "flow1")
    end

    it "fetches a specific flow" do
      stub_request(:get, "#{base_url}/flow/flow1")
        .to_return(status: 200, body: { id: "flow1" }.to_json, headers: json_headers)

      expect(client.flow("flow1")).to eq("id" => "flow1")
    end

    it "updates a flow" do
      stub_request(:put, "#{base_url}/flow/flow1")
        .with(body: { label: "Updated" }.to_json)
        .to_return(status: 200, body: { id: "flow1", label: "Updated" }.to_json, headers: json_headers)

      result = client.update_flow("flow1", { label: "Updated" })
      expect(result).to eq("id" => "flow1", "label" => "Updated")
    end

    it "deletes a flow and returns empty hash for 204" do
      stub_request(:delete, "#{base_url}/flow/flow1")
        .to_return(status: 204, body: "")

      expect(client.delete_flow("flow1")).to eq({})
    end
  end

  describe "node management" do
    it "lists nodes" do
      stub_request(:get, "#{base_url}/nodes")
        .to_return(status: 200, body: [{ id: "node-red/inject" }].to_json, headers: json_headers)

      expect(client.nodes).to eq([{ "id" => "node-red/inject" }])
    end

    it "installs a node module" do
      stub_request(:post, "#{base_url}/nodes")
        .with(body: { module: "node-red-contrib-example" }.to_json)
        .to_return(status: 200, body: { installed: true }.to_json, headers: json_headers)

      expect(client.install_node("node-red-contrib-example")).to eq("installed" => true)
    end

    it "fetches node module info" do
      stub_request(:get, "#{base_url}/nodes/node-red")
        .to_return(status: 200, body: { name: "node-red" }.to_json, headers: json_headers)

      expect(client.node_module("node-red")).to eq("name" => "node-red")
    end

    it "updates a node module" do
      stub_request(:put, "#{base_url}/nodes/node-red")
        .with(body: { enabled: false }.to_json)
        .to_return(status: 200, body: { enabled: false }.to_json, headers: json_headers)

      expect(client.update_node_module("node-red", enabled: false)).to eq("enabled" => false)
    end

    it "deletes a node module" do
      stub_request(:delete, "#{base_url}/nodes/node-red")
        .to_return(status: 204, body: "")

      expect(client.delete_node_module("node-red")).to eq({})
    end

    it "fetches node set info" do
      stub_request(:get, "#{base_url}/nodes/node-red/common")
        .to_return(status: 200, body: { id: "node-red/common" }.to_json, headers: json_headers)

      expect(client.node_set("node-red", "common")).to eq("id" => "node-red/common")
    end

    it "updates a node set" do
      stub_request(:put, "#{base_url}/nodes/node-red/common")
        .with(body: { enabled: true }.to_json)
        .to_return(status: 200, body: { enabled: true }.to_json, headers: json_headers)

      expect(client.update_node_set("node-red", "common", enabled: true)).to eq("enabled" => true)
    end
  end

  describe "authorization headers" do
    it "attaches bearer token when present" do
      stub = stub_request(:get, "#{base_url}/settings")
             .with(headers: { "Authorization" => "Bearer token" })
             .to_return(status: 200, body: {}.to_json, headers: json_headers)

      described_class.new(base_url, access_token: "token").settings
      expect(stub).to have_been_requested
    end
  end

  describe "error handling" do
    shared_examples "raises structured error" do |status, error_class|
      it "raises #{error_class} for HTTP #{status}" do
        stub_request(:get, "#{base_url}/flows")
          .to_return(status: status, body: { code: "invalid_request",
                                             message: "Problem" }.to_json, headers: json_headers)

        expect { client.flows }.to raise_error(error_class) do |error|
          expect(error.status).to eq(status)
          expect(error.code).to eq("invalid_request")
          expect(error.details).to include("code" => "invalid_request")
        end
      end
    end

    include_examples "raises structured error", 400, Node::Red::BadRequestError
    include_examples "raises structured error", 401, Node::Red::AuthenticationError
    include_examples "raises structured error", 404, Node::Red::NotFoundError
    include_examples "raises structured error", 409, Node::Red::ConflictError

    it "raises server error for 500" do
      stub_request(:get, "#{base_url}/flows")
        .to_return(status: 500, body: { message: "boom" }.to_json, headers: json_headers)

      expect { client.flows }.to raise_error(Node::Red::ServerError) do |error|
        expect(error.status).to eq(500)
        expect(error.details).to include("message" => "boom")
      end
    end

    it "raises generic API error for unknown 4xx status" do
      stub_request(:get, "#{base_url}/flows")
        .to_return(status: 418, body: {}.to_json, headers: json_headers)

      expect { client.flows }.to raise_error(Node::Red::ApiError) do |error|
        expect(error.status).to eq(418)
      end
    end

    it "raises unexpected response error for invalid JSON" do
      stub_request(:get, "#{base_url}/flows")
        .to_return(status: 200, body: "<html>")

      expect { client.flows }.to raise_error(Node::Red::UnexpectedResponseError) do |error|
        expect(error.status).to eq(200)
        expect(error.details).to eq(body: "<html>")
      end
    end

    it "handles empty error body" do
      stub_request(:get, "#{base_url}/flows")
        .to_return(status: 400, body: "")

      expect { client.flows }.to raise_error(Node::Red::BadRequestError) do |error|
        expect(error.status).to eq(400)
        expect(error.code).to be_nil
        expect(error.details).to be_nil
      end
    end

    it "includes raw body when error JSON is invalid" do
      stub_request(:get, "#{base_url}/flows")
        .to_return(status: 400, body: "oops")

      expect { client.flows }.to raise_error(Node::Red::BadRequestError) do |error|
        expect(error.details).to eq(raw_body: "oops")
      end
    end
  end
end
