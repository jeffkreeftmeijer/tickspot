require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Tickspot do
  it 'should set the company' do
    Tickspot.company = 'c0mp4ny'
    Tickspot.company.should == 'c0mp4ny'
  end
  
  it 'should set the email' do
    Tickspot.email = 'my@email.com'
    Tickspot.email.should == 'my@email.com'
  end
  
  it 'should set the password' do
    Tickspot.password = 'secret'
    Tickspot.password.should == 'secret'
  end
end

describe Tickspot::Request do
  describe '.post' do
    it 'should do a post request with the parameters' do
      HTTParty.should_receive(:post).with(
        'https://c0mp4ny.tickspot.com/api/clients',
        :query => {
          :email =>     'my@email.com',
          :password =>  'secret'
        }
      )

      Tickspot::Request.post(
        :section => :clients
      )
    end

    it 'should pass every argument in the query hash' do
      HTTParty.should_receive(:post).with(
        'https://c0mp4ny.tickspot.com/api/clients',
        :query => {
          :email =>     'my@email.com',
          :password =>  'secret',
          :woo =>       'bleh'
        }
      )

      Tickspot::Request.post(
        :section =>   :clients,
        :woo =>       'bleh'
      )
    end
  end
end

describe Tickspot::Base do
  describe '.all' do
    before do
      class BaseTest < Tickspot::Base
        def self.section
          :tests
        end
      end
    end
    
    it 'should send a request' do
      Tickspot::Request.should_receive(:post).with(
        :section => :tests
      )
      BaseTest.all
    end
  end
end

describe Tickspot::Client do
  it 'should have :clients as its section' do
    Tickspot::Client.section.should == :clients
  end
end

describe Tickspot::Project do
  it 'should have :projects as its section' do
    Tickspot::Project.section.should == :projects
  end
end

describe Tickspot::Task do
  it 'should have :tasks as its section' do
    Tickspot::Task.section.should == :tasks
  end
end

describe Tickspot::ClientProjectTask do
  it 'should have :clients_projects_tasks as its section' do
    Tickspot::ClientProjectTask.section.should == :clients_projects_tasks
  end
end

describe Tickspot::Entry do
  it 'should have :entries as its section' do
    Tickspot::Entry.section.should == :entries
  end
end

describe Tickspot::RecentTask do
  it 'should have :recent_tasks as its section' do
    Tickspot::RecentTask.section.should == :recent_tasks
  end
end

describe Tickspot::User do
  it 'should have :users as its section' do
    Tickspot::User.section.should == :users
  end
end
