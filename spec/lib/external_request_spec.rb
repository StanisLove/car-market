require "rails_helper"

describe ExternalRequest do
  subject(:external_request) { described_class.new(input) }

  let(:input) do
    {
      endpoint: endpoint,
      query_params: query_params,
      method: method
    }.compact
  end

  let(:query_params) { nil }
  let(:method) { nil }
  let(:endpoint) { "https://example.com" }

  describe "#call" do
    subject(:call) { external_request.call }

    before do
      stub_request(:any, endpoint).with(query: query_params)
      call
    end

    it "makes get request" do
      expect(
        a_request(:get, endpoint).with(query: {})
      ).to have_been_made
    end

    context "when post method privided" do
      let(:method) { :post }

      it "makes post request" do
        expect(
          a_request(:post, endpoint).with(query: {})
        ).to have_been_made
      end
    end

    context "when query params provided" do
      let(:query_params) { Hash[a: 1] }

      it "pass query params" do
        expect(
          a_request(:get, endpoint).with(query: {"a" => 1})
        ).to have_been_made
      end
    end
  end

  describe "#response" do
    subject(:response) { external_request.response.as_json }

    before do
      stub_request(:any, endpoint).with(query: query_params)
        .to_return(
          body: '[{"a": 1}]',
          headers: {content_type: 'application/json'}
        )
      external_request.call
    end

    specify do
      is_expected.to eq(["a" => 1])
    end
  end
end
