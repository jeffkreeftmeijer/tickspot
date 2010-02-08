require 'rubygems'
require 'httparty'

module Tickspot
  class << self
    attr_accessor :company, :email, :password
  end

  class Request
    def self.post(options)
      HTTParty.post(
        "https://#{Tickspot.company}.tickspot.com/" <<
          "api/#{options.delete(:section)}",
        :query => options.merge({
          :email =>     Tickspot.email,
          :password =>  Tickspot.password
        })
      )
    end
  end
  
  class Base
    def self.all
      Request.post(:section => section)
    end
  end
  
  class Client < Base
    def self.section
      :clients
    end
  end
  
  class Project < Base
    def self.section
      :projects
    end
  end
  
  class Task < Base
    def self.section
      :tasks
    end
  end
  
  class ClientProjectTask < Base
    def self.section
      :clients_projects_tasks
    end
  end
  
  class Entry < Base
    def self.section
      :entries
    end
  end
  
  class RecentTask < Base
    def self.section
      :recent_tasks
    end
  end
  
  class User < Base
    def self.section
      :users
    end
  end
end
