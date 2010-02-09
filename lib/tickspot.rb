require 'rubygems'
require 'httparty'

module Tickspot
  class << self
    attr_accessor :company, :email, :password
  end

  class Request

    ##
    # Send a post request to Tickspot. Will use Tickspot.company and
    # Tickspot.section to build the url and passes every op tion it received (
    # merged with Tickspot.email and Tickspot.password ) to HTTParty's :query
    # parameter. It'll return everythin within the returned root node ( which
    # is named equally to the section name ).
    #
    # @param [Hash] options The options you want to pass.
    #
    # @return [Array] items An array of hashes with the item data.

    def self.post(options)
      section = options.delete(:section)
      result = HTTParty.post(
        "https://#{Tickspot.company}.tickspot.com/api/#{section}",
        :query => options.merge({
          :email =>     Tickspot.email,
          :password =>  Tickspot.password
        })
      )
      result[section.to_s]
    end
  end

  class Base
    attr_reader :attributes

    ##
    # Create a new Tickspot::Base object. Will put the data provided in
    # the @attributes attribute.
    #
    # @param [Hash] data The item's data.
    #
    # @return [Tickspot::Base] object The created object.

    def initialize(data)
      @attributes = data
    end

    ##
    # Fetch the missing methods. Will fetch all missing methods executed on a
    # Tickspot::Base object and use the method_id as a key to find a value in
    # the object's @attributes. If the value found is an Array, it'll create a
    # wrap it into a new object using the name to determine which one.
    #
    # @param [symbol] method_id The name of the missing method.
    # @param [*] *args Additional arguments.
    #
    # @return [*] value The found value.

    def method_missing(method_id, *args)
      value = @attributes[method_id.to_s]
      if value.is_a? Array
        return value.map do |item|
          self.class.sections.index(method_id).new(item)
        end
      end
      value
    end

    ##
    # The item id. Will return @attributes['id']
    #
    # @return [Integer] id The item id

    def id
      @attributes['id']
    end
    
    ##
    # The object section. Needs to be called by an extending class. Will get
    # the section (to be passed to Tickspot in the url) from self.sections 
    # using the constant name.
    #
    # @return [Symbol] section The object section
    
    def self.section
      sections[self]
    end

    ##
    # Fetch all items and return them in an array of objects. Will get the
    # section using self.section (so Tickspot::Base needs to be extended) and
    # merge that with any passed arguments to pass to Request.post. Every hash
    # in the returned array will get wrapped in an item object.
    #
    # @return [Array] items An array of item objects.

    def self.all(options = {})
      result = Request.post(
        options.merge({
          :section => section
        })
      )
      result.map{|item| new(item)} if result
    end

    ##
    # The list to convert constant names to section symbols.
    #
    # @return [Hash] sections The list of sections.

    def self.sections
      {
        Tickspot::Client =>             :clients,
        Tickspot::Project =>            :projects,
        Tickspot::Task =>               :tasks,
        Tickspot::ClientProjectTask =>  :clients_projects_tasks,
        Tickspot::Entry =>              :entries,
        Tickspot::RecentTask =>         :recent_tasks,
        Tickspot::User =>               :users,
        Tickspot::CreateEntry =>        :create_entry,
        Tickspot::UpdateEntry =>        :update_entry
      }
    end
  end
 
  class Client < Base; end
  
  class Project < Base; end

  class Task < Base; end

  class ClientProjectTask < Base; end
  
  class Entry < Base; end

  class RecentTask < Base; end

  class User < Base; end

  class CreateEntry < Base; end

  class UpdateEntry < Base; end

end
