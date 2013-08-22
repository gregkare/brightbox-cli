require "spec_helper"

describe Brightbox::Config::ApiClient do
  let(:client_name) { "cli-12345" }
  let(:secret) { random_token }

  let(:config) { config_from_contents(contents) }
  let(:config_section) { config[client_name] }

  subject(:section) { Brightbox::Config::ApiClient.new(config_section, client_name) }
  subject(:for_fog) { section.to_fog }

  describe "#to_fog" do
    context "when config is valid" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        client_id = #{client_name}
        secret = #{secret}
        EOS
      end

      it "sets provider as 'Brightbox'" do
        expect(for_fog[:provider]).to eql("Brightbox")
      end

      it "sets API endpoint correctly" do
        expect(for_fog[:brightbox_api_url]).to eql("http://api.dev.brightbox.com")
      end

      it "copies API endpoint for auth endpoint correctly" do
        expect(for_fog[:brightbox_auth_url]).to eql("http://api.dev.brightbox.com")
      end

      it "sets client_id correctly" do
        expect(for_fog[:brightbox_client_id]).to eql(client_name)
      end

      it "sets secret correctly" do
        expect(for_fog[:brightbox_secret]).to eql(secret)
      end

      it "sets persistent correctly" do
        expect(for_fog[:persistent]).to be_true
      end
    end

    context "when config has alternative auth endpoint" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        auth_url = http://auth.dev.brightbox.com
        client_id = #{client_name}
        secret = #{secret}
        EOS
      end

      it "sets API endpoint correctly" do
        expect(for_fog[:brightbox_api_url]).to eql("http://api.dev.brightbox.com")
      end

      it "copies API endpoint for auth endpoint correctly" do
        expect(for_fog[:brightbox_auth_url]).to eql("http://auth.dev.brightbox.com")
      end
    end

    context "when config has persistence setting" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        client_id = #{client_name}
        secret = #{secret}
        persistent = false
        EOS
      end

      it "sets persistent correctly" do
        expect(for_fog[:persistent]).to be_true
      end
    end

    context "when config is missing api_url" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        client_id = #{client_name}
        secret = #{random_token}
        EOS
      end

      it "raises error" do
        expect { section.to_fog }.to raise_error
      end
    end

    context "when config is missing client_id" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        secret = #{random_token}
        EOS
      end

      it "raises error" do
        expect { section.to_fog }.to raise_error
      end
    end

    context "when config is missing secret" do
      let(:contents) do
        <<-EOS
        [#{client_name}]
        api_url = http://api.dev.brightbox.com
        client_id = #{client_name}
        EOS
      end

      it "raises error" do
        expect { section.to_fog }.to raise_error
      end
    end
  end
end