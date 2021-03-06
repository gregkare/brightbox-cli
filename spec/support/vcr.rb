require "vcr"

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |vcr|
  vcr.cassette_library_dir = File.join(File.dirname(__FILE__), "../cassettes")
  vcr.allow_http_connections_when_no_cassette = false
  vcr.hook_into :excon

  vcr.configure_rspec_metadata!
  vcr.default_cassette_options = {
    :record => :none,
    #:record => :new_episodes,
    :match_requests_on => [:method, :path, :body],
    :update_content_length_header => true
  }

  # Gives lots of clues about how VCR is running
  # vcr.debug_logger = $stderr

  vcr.before_record do |interaction|
    host = URI.parse(interaction.request.uri).host
    interaction.request.uri.gsub!(host, "api.brightbox.dev")

    # Sanitise identifiers as best as we can
    # We need the poser of Regexp so filter_sensitive doesn't help
    %w(acc col cip fwp fwr grp img lba srv typ usr zon).each do |prefix|
      id_pattern = /#{prefix}-[0-9a-z]+/
      interaction.request.uri.gsub!(id_pattern, "#{prefix}-12345")
      interaction.request.body.gsub!(id_pattern, "#{prefix}-12345")
      interaction.response.body.gsub!(id_pattern, "#{prefix}-12345")
    end
  end
end
