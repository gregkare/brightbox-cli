module Brightbox
  # The length of the identifier string.
  IDENTIFIER_SIZE = 9

  class Api
    attr_reader :id
    class ApiError < StandardError ; end
    class NotFound < ApiError ; end
    class Conflict < ApiError ; end
    class InvalidRecord < ApiError ; end
    class Forbidden < ApiError ; end
    class InvalidArguments < ApiError ; end

    @@connection_manager = nil

    # Returns the current connection to the Brightbox API, creating a new
    # {ConnectionManager} and connection if necessary.
    #
    # @return [Fog::Compute::Brightbox::Real]
    #
    def self.conn
      if @@connection_manager
        @@connection_manager.fetch_connection(require_account?)
      else
        @@connection_manager = Brightbox::ConnectionManager.new($config.to_fog)
        @@connection_manager.fetch_connection(require_account?)
      end
    end

    # Returns +true+ if instances of this class require account details to be
    # used. This changes the type of connection needed and the authentication
    # details.
    #
    # @return [Boolean]
    #
    def self.require_account?; false; end

    #
    #
    # @return [String] the 'name' of the class
    #
    def self.klass_name
      name.split("::").last
    end

    def initialize(m = nil)
      if m.is_a? String
        @id = m
      elsif m.respond_to?(:attributes) && m.respond_to?(:id)
        @fog_model = m
        @id = m.id
      else
        raise InvalidArguments, "Can't initialize #{self.class} with #{m.inspect}"
      end
      $config.cache_id(@id) if $config.respond_to?(:cache_id)
    end

    def fog_model
      @fog_model ||= self.class.find(@id)
    end

    def exists?
      !fog_model.nil?
    rescue NotFound
      false
    end

    def to_s
      @id
    end

    # Will return everything unless a subset has been passed in
    #
    # @param [Array<String>] identifiers series of values to call to call
    #
    def self.find_all_or_warn(identifiers)
      if identifiers.empty?
        find(:all)
      else
        find_or_call(identifiers) do |identifier|
          warn "Could not find anything with ID #{identifier}"
        end
      end
    end

    # General finder to return instances based on identifiers or all.
    #
    # @param args    [Array<Object>, Object] Search settings. Passing +:all+
    #   will return all resources. An identifier (String) will return that one
    #   and a collection of strings will return those resources.
    # @param options [Hash]
    #
    # @return [Array<Object>] A collection of API models
    # @return [Object] A single API model if requested with a single identifier
    #
    # @raise [Brightbox::Api::InvalidArguments] if +args+ can not be used to
    #   search for.
    #
    def self.find(args = :all, options = {})
      raise InvalidArguments, "find(nil)" if args.nil?
      raise InvalidArguments, "find([])" if args.respond_to?(:empty?) && args.empty?
      options = { :order => :created_at }.merge(options)

      objects = nil
      object = nil
      # get the data from the Api
      if args == :all
        objects = all
      elsif args.is_a? String
        object = cached_get(args.to_s)
        raise NotFound, "Couldn't find '#{args}'" if object.nil?
      elsif args.respond_to? :map
        objects = args.map do |arg|
          o = cached_get(arg.to_s)
          raise NotFound, "Couldn't find '#{arg}'" if o.nil?
          o
        end
      else
        raise InvalidArguments, "Couldn't find '#{args.class}'"
      end
      if objects
        # wrap in our objects
        objects.map! { |o| new(o) }
        # Sort
        objects.sort! do |a, b|
          sort_method = options[:order]
          begin
            a.send(sort_method) <=> b.send(sort_method)
          rescue NoMethodError
            0
          end
        end
        objects
      elsif object
        new(object)
      end
    end

    # Find each id in the given array.  Yield the block with any ids
    # that couldn't be found
    def self.find_or_call(ids, &_block)
      objects = []
      ids.each do |id|
        begin
          objects << find(id)
        rescue Api::NotFound
          yield id
        end
      end
      objects
    end

    def method_missing(m, *args)
      if fog_model
        fog_model.send(m, *args)
      else
        raise NoMethodError
      end
    end

    def self.cached_get(id)
      @cache ||= {}
      value = @cache[id]
      if value
        value
      else
        $config.cache_id id
        @cache[id] = get(id)
      end
    end

    def self.find_by_handle(h)
      object = find(:all).find { |o| o.handle == h }
      raise Api::NotFound, "Invalid #{klass_name} #{h}" if object.nil?
      object
    end

    def self.cache_all!
      @cache = {}
      all.each do |f|
        @cache[f.id] = f
        $config.cache_id f.id
      end
    end

    # Displays creation date in ISO 8601 Complete date format
    #
    def created_on
      fog_model.created_at.strftime("%Y-%m-%d")
    end
  end
end
