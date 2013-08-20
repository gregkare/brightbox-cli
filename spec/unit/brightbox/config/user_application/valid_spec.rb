require "spec_helper"

describe Brightbox::Config::UserApplication do
  let(:client_name) { "app-12345" }
  let(:config) { config_from_contents(contents) }
  let(:config_section) { config[client_name] }

  subject(:section) { Brightbox::Config::UserApplication.new(config_section, client_name) }

  describe "#valid?" do
    context "when config is valid" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        app_id = #{client_name}
        app_secret = #{random_token}
        refresh_token = #{random_token}
        EOS
      end

      it "is valid" do
       expect(section).to be_valid
      end
    end

    context "when config has additional values" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        app_id = #{client_name}
        app_secret = #{random_token}
        refresh_token = #{random_token}
        theme = blue
        EOS
      end

      it "is valid" do
       expect(section).to be_valid
      end
    end

    context "when config is missing api_url" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        app_id = #{client_name}
        app_secret = #{random_token}
        refresh_token = #{random_token}
        EOS
      end

      it "is invalid" do
       expect(section).to_not be_valid
      end
    end

    context "when config is missing app_id" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        app_secret = #{random_token}
        refresh_token = #{random_token}
        EOS
      end

      it "is invalid" do
       expect(section).to_not be_valid
      end
    end

    context "when config is missing app_secret" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        app_id = #{client_name}
        refresh_token = #{random_token}
        EOS
      end

      it "is invalid" do
       expect(section).to_not be_valid
      end
    end

    context "when config is missing refresh_token" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        app_id = #{client_name}
        app_secret = #{random_token}
        EOS
      end

      it "is invalid" do
       expect(section).to_not be_valid
      end
    end
  end
end
