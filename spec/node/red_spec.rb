# frozen_string_literal: true

RSpec.describe Node::Red do
  it "has a version number" do
    expect(Node::Red::VERSION).not_to be nil
  end

  it "provides access to Client class" do
    expect(Node::Red::Client).to be_a(Class)
  end

  it "provides error classes" do
    expect(Node::Red::ApiError).to be_a(Class)
    expect(Node::Red::AuthenticationError).to be_a(Class)
    expect(Node::Red::NotFoundError).to be_a(Class)
    expect(Node::Red::ServerError).to be_a(Class)
  end
end
