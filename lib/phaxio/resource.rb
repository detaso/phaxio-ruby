module Phaxio
  # The base class for API resources, such as `Fax` and `PhoneNumber`.
  #
  # This class is considered an implementation detail, and shouldn't be directly relied upon by
  # users.
  #
  # The only exception is that this class will continue to be the base class for all Phaxio
  # resources, so checking whether a fax instance is a kind of Phaxio::Resource will always return
  # true.
  class Resource
    private

    # The raw response data
    attr_accessor :raw_data

    # Populates the instance's attributes based on the `raw_data`.
    def populate_attributes
      self.class.normal_attribute_list.each do |normal_attribute|
        public_send "#{normal_attribute}=", raw_data[normal_attribute]
      end

      self.class.time_attribute_list.each do |time_attribute|
        time = raw_data[time_attribute]
        time = Time.parse(time) if !time.nil?
        public_send "#{time_attribute}=", time
      end

      self.class.collection_attribute_mappings.each do |collection_attribute, klass|
        collection = raw_data[collection_attribute] || []
        collection = {"data" => collection}
        collection = klass.response_collection(collection)
        public_send "#{collection_attribute}=", collection
      end
    end

    # @see Phaxio::Resource.response_record
    def initialize raw_data
      self.raw_data = raw_data
      populate_attributes
    end

    class << self
      # @api private
      # Returns a new instance of the resource for this data.
      # @param raw_data [Hash] The raw response data from Phaxio.
      # @return [Phaxio::Resource] The resource instance.
      def response_record raw_data
        new raw_data
      end

      # @api private
      # Returns a new collection of resource instances for this data.
      # @param raw_data [Array] The raw response data from Phaxio.
      # @return [Phaxio::Resource::Collection] A collection of Phaxio::Resource instances.
      def response_collection raw_data
        Collection.new raw_data, self
      end

      # @api private
      # Full list of resource-specific attributes.
      attr_accessor :attribute_list

      # @api private
      # List of resource-specific attributes that don't require additional processing during
      # instance data population.
      attr_accessor :normal_attribute_list

      # @api private
      # List of resource-specific attributes that must be parsed into a Time object during instance
      # data population.
      attr_accessor :time_attribute_list

      # @api private
      # Mapping of resource-specific attributes that must be parsed into a resource collection.
      attr_accessor :collection_attribute_mappings

      private :new

      private

      # Creates accessors for the given normal attributes and adds them to the class's internal
      # attribute lists.
      # @param attribute_list [Array]
      #   A list of attributes as strings or symbols.
      # @see Phaxio::Resource.normal_attribute_list
      def has_normal_attributes attribute_list
        attribute_list = attribute_list.map { |attribute_name| attribute_name.to_s.freeze }
        attr_accessor(*attribute_list)
        self.attribute_list += attribute_list
        self.normal_attribute_list += attribute_list
      end

      # Creates accessors for the given time attributes and adds them to the class's internal
      # attribute lists.
      # @param attribute_list [Array]
      #   A list of attributes as strings or symbols.
      # @see Phaxio::Resource.time_attribute_list
      def has_time_attributes attribute_list
        attribute_list = attribute_list.map { |attribute_name| attribute_name.to_s.freeze }
        attr_accessor(*attribute_list)
        self.attribute_list += attribute_list
        self.time_attribute_list += attribute_list
      end

      # Creates accessors for the given collection attributes and adds them to the class's internal
      # attribute lists.
      # @param attribute_hash [Hash<String, Symbol => Phaxio::Resource>]
      #   A hash which has keys corresponding to the attribute name on this resource, and values
      #   corresponding to the resource class for the collection's items.
      # @see Phaxio::Resource.collection_attribute_mappings
      def has_collection_attributes attribute_hash
        # Array#to_h doesn't exist in 2.0.0, hence the inject here.
        attribute_hash = attribute_hash
          .map { |k, v| [k.to_s.freeze, v] }
          .inject({}) { |memo, obj| memo.tap { |memo| memo[obj.first] = obj.last } }
        attr_accessor(*attribute_hash.keys)
        self.attribute_list += attribute_hash.keys
        self.collection_attribute_mappings = collection_attribute_mappings.merge(attribute_hash)
      end

      # Use the inherited hook to dynamically set each subclass's attribute lists to empty arrays
      # upon creation.
      def inherited subclass
        subclass.attribute_list = []
        subclass.normal_attribute_list = []
        subclass.time_attribute_list = []
        subclass.collection_attribute_mappings = {}
      end
    end

    class Collection
      include Enumerable

      # The raw response data
      attr_accessor :raw_data, :collection, :total, :per_page, :page

      # Returns a new collection of resource instances for this data. Generally this is not called
      # directly.
      #
      # @see Phaxio::Resource.response_collection
      def initialize response_data, resource
        # For some endpoints we'll get a hash with `paging` and `data` attributes.
        # For others, just an array.
        if response_data.is_a? Hash
          if response_data.key? "paging"
            self.total = response_data["paging"]["total"]
            self.per_page = response_data["paging"]["per_page"]
            self.page = response_data["paging"]["page"]
          end
          self.raw_data = response_data["data"]
        else
          self.raw_data = response_data
        end
        self.collection = raw_data.map { |record_data| resource.response_record record_data }
      end

      def [] idx
        collection[idx]
      end

      def each(&block)
        collection.each(&block)
      end

      def length
        collection.length
      end

      def size
        length
      end
    end
  end
end
