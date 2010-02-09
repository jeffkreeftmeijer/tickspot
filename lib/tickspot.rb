require 'rubygems'
require 'httparty'

module Tickspot
  class << self
    attr_accessor :company, :email, :password
  end

  class Request
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

    def initialize(data)
      @attributes = data
    end

    def method_missing(method_id, *args)
      value = @attributes[method_id.to_s]
      if value.is_a? Array
        return value.map do |item|
          self.class.sections.index(method_id).new(item)
        end
      end
      value
    end

    def id
      @attributes['id']
    end

    def self.section
      sections[self]
    end

    def self.all(options = {})
      result = Request.post(
        options.merge({
          :section => section
        })
      )
      result.map{|item| new(item)} if result
    end

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
