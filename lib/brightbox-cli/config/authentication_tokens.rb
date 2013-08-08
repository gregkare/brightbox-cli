module Brightbox
  module Config
    module AuthenticationTokens

      def oauth_token_filename
        @oauth_token_filename ||= File.join(config_directory, client_name + '.oauth_token')
      end

      def oauth_token
        return @oauth_token if defined?(@oauth_token)
        if File.exists?(oauth_token_filename)
          @oauth_token = read_cached_token
        else
          @oauth_token = nil
        end
      end

      def save_refresh_token
        if Api.conn.refresh_token && !Api.conn.refresh_token.empty?
          selected_config['refresh_token'] = Api.conn.refresh_token
          save!
        end
      end

      def update_refresh_token
        return false unless using_application?
        require 'highline'
        highline = HighLine.new()
        highline.say("Your API credentials have expired, enter your password to update them.")
        password = highline.ask("Enter your password : ") { |q| q.echo = false }
        fetch_refresh_token(:client_id => client_name, :email => selected_config['email'], :password => password)
        save!
        highline.say("Your API credentials have been updated, please re-run your command.")
        true
      end

      def fetch_refresh_token(options)
        self.client_name = options[:client_id]
        client_config = config[client_name]
        user_application = Brightbox::Config::UserApplication.new(client_config, client_name)
        # replace this portion with code that actually fetches a token
        client_config['refresh_token'] = user_application.fetch_refresh_token(options)
      end

    private

      def read_cached_token
        File.open(oauth_token_filename, "r") { |fl| fl.read.chomp }
      end

    end
  end
end