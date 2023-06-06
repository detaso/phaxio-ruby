module Phaxio
  module Resources
    # Provides functionality for managing ATAs.
    class Ata < Resource
      ATAS_PATH = "atas".freeze
      private_constant :ATAS_PATH

      # @return [Integer] the ID of the ATA.
      # @!attribute id

      # @return [String] the name of the ATA.
      # @!attribute name

      # @return [String] the description of the ATA.
      # @!attribute description

      # @return [String] The user phone number associated with the ATA.
      # @!attribute user_phone_number

      # @return [String] The domain for the ATA.
      # @!attribute domain

      # @return [String] The user agent for the ATA.
      # @!attribute user_agent

      # @return [String] The SIP URI for the ATA.
      # @!attribute sip_uri

      # @return [String] The mac address for the ATA.
      # @!attribute mac_address

      # @return [String] The name of the group which the ATA belongs to.
      # @!attribute group

      # @return [String] The username for the ATA.
      # @!attribute username

      # @return [String] The password for the ATA.
      # @!attribute password

      has_normal_attributes %w[
        id name description user_phone_number domain user_agent sip_uri
        mac_address group username password
      ]

      # @return [Time] The time at which the ATA was last registered.
      # @!attribute last_registered

      # @return [Time] The time at which the ATA's registration expires.
      # @!attribute expiry_time

      has_time_attributes %w[
        last_registered expiry_time
      ]

      # A reference to an ATA. This is returned by certain actions which don't
      # return the full ATA.
      class Reference
        # @return [Integer]
        #   The ID of the referenced ATA.
        attr_accessor :id

        def to_i
          id
        end

        # Gets the referenced ATA.
        # @return [Phaxio::Resources::ATA]
        def get
          Ata.get self
        end
        alias_method :retrieve, :get
        alias_method :find, :get

        private

        def initialize id
          self.id = id
        end
      end

      # A set of provisioning URLs.
      class ProvisioningURLs
        # @return [Hash<String: String>] The hash of provisioning URLs.
        # @!attribute urls
        attr_reader :urls

        GRANDSTREAM = "Grandstream"
        OBI = "OBi"
        NETGEN = "Netgen"

        def initialize data
          @urls = data
        end

        # @return [String] The Grandstream provisioning url.
        def grandstream
          urls.fetch(GRANDSTREAM)
        end

        # @return [String] The OBi provisioning url.
        def obi
          urls.fetch(OBI)
        end

        # @return [String] The Netgen provisioning url.
        def netgen
          urls.fetch(NETGEN)
        end
      end

      class << self
        # @macro paging
        # List ATAs
        # @param params[Hash]
        #   Any parameters to send to Phaxio.
        # @return [Phaxio::Resource::Collection<Phaxio::Resources::Ata>]
        #   The collection of ATAs matching your request.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/list
        def list params = {}
          response = Client.request :get, atas_endpoint, params
          response_collection response
        end

        # Create an ATA
        # @param params [Hash]
        #   Any parameters to send to Phaxio.
        #   - *name* [String] - A name used to identify the ATA.
        #   - *description* [String] - A longer description of the ATA.
        #   - *domain* [String] - A domain for the ATA.
        #   - *mac_address* [String] - A mac address for the ATA.
        # @return [Phaxio::Resources::Ata]
        #   The created ATA, including the generated username and password.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/create
        def create params = {}
          response = Client.request :post, atas_endpoint, params
          response_record response
        end

        # Get an ATA
        # @param id [Integer]
        #   The ID of the ATA to retrieve information about.
        # @param params [Hash]
        #   Any parameters to send to Phaxio.
        #   - *with_credentials* [Boolean] - If enabled, the username and
        #     password for the ATA will be included in the response.
        # @return [Phaxio::Resources::Ata]
        #   The requested ATA.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/get
        def get id, params = {}
          response = Client.request :get, ata_endpoint(id.to_i), params
          response_record response
        end
        alias_method :retrieve, :get
        alias_method :find, :get

        # Update an ATA
        # @param id [Integer]
        #   The ID of the ATA to update.
        # @param params [Hash]
        #   Any parameters to send to Phaxio.
        #   - *name* [String] - A name used to identify the ATA.
        #   - *description* [String] - A longer description of the ATA.
        #   - *mac_address* [String] - A mac address for the ATA.
        # @return [Phaxio::Resources::Ata]
        #   The updated ATA.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/update
        def update id, params = {}
          response = Client.request :patch, ata_endpoint(id.to_i), params
          response_record response
        end

        # Regenerate credentials for an ATA
        # @param id [Integer]
        #   The ID of the ATA for which credentials should be regenerated.
        # @param params [Hash]
        #   Any parameters to send to Phaxio. This action takes no unique parameters.
        # @return [Phaxio::Resources::Ata]
        #   The ATA, including the new username and password.
        # @raise Phaxio::Error::PhaxioError
        # @see https://www.phaxio.com/docs/api/v2.1/atas/regenerate_credentials
        def regenerate_credentials id, params = {}
          response = Client.request :patch, regenerate_credentials_endpoint(id.to_i), params
          response_record response
        end

        # Delete an ATA
        # @param id [Integer]
        #   The ID of the ATA to delete.
        # @param params [Hash]
        #   Any parameters to send to Phaxio. This action takes no unique parameters.
        # @return [Phaxio::Resources::Ata::Reference]
        #   A reference to the deleted ATA.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/delete
        def delete id, params = {}
          response = Client.request :delete, ata_endpoint(id.to_i), params
          response_reference response
        end

        # Add a phone number
        # @param id [Integer]
        #   The ID of the ATA to which you want to add a number.
        # @param phone_number [String]
        #   The phone number to add to the ATA.
        # @param params [Hash]
        #   Any parameters to send to Phaxio. This action takes no unique parameters.
        # @return [Phaxio::Resources::PhoneNumber::Reference]
        #   A reference to the added phone number.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/add_phone_number
        def add_phone_number id, phone_number, params = {}
          response = Client.request :post, phone_number_endpoint(id, phone_number), params
          response_phone_number_reference response
        end

        # Remove a phone number
        # @param id [Integer]
        #   The ID of the ATA from which you want to remove the phone number.
        # @param phone_number [String]
        #   The phone number you want to remove.
        # @param params [Hash]
        #   Any parameters to send to Phaxio. This action takes no unique parameters.
        # @return [Phaxio::Resources::PhoneNumber::Reference]
        #   A reference to the removed phone number.
        # @raise [Phaxio::Error::PhaxioError]
        # @see https://www.phaxio.com/docs/api/v2.1/atas/remove_phone_number
        def remove_phone_number id, phone_number, params = {}
          response = Client.request :delete, phone_number_endpoint(id, phone_number), params
          response_phone_number_reference response
        end

        # Get ATA provisioning URLs for your Phaxio account.
        # @param params [Hash]
        #   Any parameters to send to Phaxio.
        #   - *group* [String] - If given, this action instead returns
        #     provisioning URLs for the named group.
        # @return [Phaxio::Resources::Ata::ProvisioningURLs
        # @see https://www.phaxio.com/docs/api/v2.1/atas/provisioning_urls
        def provisioning_urls params = {}
          response = Client.request :get, provisioning_urls_endpoint, params
          response_provisioning_urls response
        end

        private

        def response_reference response
          Reference.new Integer(response["id"])
        end

        def response_phone_number_reference response
          PhoneNumber::Reference.new(response["phone_number"])
        end

        def response_provisioning_urls response
          ProvisioningURLs.new(response)
        end

        def atas_endpoint
          ATAS_PATH
        end

        def ata_endpoint id
          "#{atas_endpoint}/#{id}"
        end

        def regenerate_credentials_endpoint id
          "#{ata_endpoint(id)}/regenerate_credentials"
        end

        def phone_number_endpoint id, phone_number
          "#{ata_endpoint(id)}/phone_numbers/#{phone_number}"
        end

        def provisioning_urls_endpoint
          "#{atas_endpoint}/provisioning_urls"
        end
      end
    end
  end
end
