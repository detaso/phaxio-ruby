require "spec_helper"

RSpec.describe Public::Country do
  describe "getting a list of supported countries", vcr: "public/country/list" do
    let(:action) { Public::Country.list }
    let(:params) { {} }

    it "makes the request to Phaxio" do
      expect_api_request :get, "public/countries", params
      action
    end

    it "returns a collection of supported country resources" do
      result = action
      expect(result).to be_a(Phaxio::Resource::Collection)
    end
  end
end
