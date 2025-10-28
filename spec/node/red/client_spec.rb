# frozen_string_literal: true

RSpec.describe Node::Red::Client do
  let(:base_url) { "http://localhost:1880" }
  let(:client) { described_class.new(base_url) }
  let(:authenticated_client) { described_class.new(base_url, access_token: "test-token") }

  describe "#initialize" do
    it "sets the base URL" do
      expect(client.base_url).to eq(base_url)
    end

    it "strips trailing slash from base URL" do
      client_with_slash = described_class.new("http://localhost:1880/")
      expect(client_with_slash.base_url).to eq(base_url)
    end

    it "sets the access token when provided" do
      expect(authenticated_client.access_token).to eq("test-token")
    end

    it "has nil access token when not provided" do
      expect(client.access_token).to be_nil
    end
  end

  describe "error classes" do
    it "defines ApiError" do
      expect(Node::Red::ApiError).to be < StandardError
    end

    it "defines AuthenticationError" do
      expect(Node::Red::AuthenticationError).to be < Node::Red::ApiError
    end

    it "defines NotFoundError" do
      expect(Node::Red::NotFoundError).to be < Node::Red::ApiError
    end

    it "defines ServerError" do
      expect(Node::Red::ServerError).to be < Node::Red::ApiError
    end
  end

  # Add more specs with WebMock for testing actual HTTP calls
  # Example:
  # describe "#settings" do
  #   it "returns settings" do
  #     stub_request(:get, "#{base_url}/settings")
  #       .to_return(status: 200, body: { httpNodeRoot: "/" }.to_json)
  #
  #     settings = client.settings
  #     expect(settings["httpNodeRoot"]).to eq("/")
  #   end
  # end
end
