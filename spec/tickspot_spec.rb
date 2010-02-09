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
    before do
      @result = {'tests' => []}
    end
    
    it 'should do a post request with the parameters' do
      HTTParty.should_receive(:post).with(
        'https://c0mp4ny.tickspot.com/api/tests',
        :query => {
          :email =>     'my@email.com',
          :password =>  'secret'
        }
      ).and_return(@result)

      Tickspot::Request.post(
        :section => :tests
      )
    end

    it 'should pass every argument in the query hash' do
      HTTParty.should_receive(:post).with(
        'https://c0mp4ny.tickspot.com/api/tests',
        :query => {
          :email =>     'my@email.com',
          :password =>  'secret',
          :woo =>       'bleh'
        }
      ).and_return(@result)

      Tickspot::Request.post(
        :section =>   :tests,
        :woo =>       'bleh'
      )
    end
    
    it 'should strip the top level node' do
      HTTParty.stub!(:post).and_return(@result)
      
      Tickspot::Request.post(
        :section => :tests
      ).should == []
    end
  end
end

describe Tickspot::Base do
  before do
    class BaseTest < Tickspot::Base
      def self.section
        :tests
      end
    end
    
    @test = BaseTest.new({'id' => 14, 'name' => 'test!'})
  end
  
  describe '#new' do
    it 'should set the attributes' do
      @test.attributes.should == {'id' => 14, 'name' => 'test!'}
    end
  end
  
  describe '#method_missing' do
    it 'should find the attribute' do
      @test.name.should == 'test!'
    end
    
    it 'should turn nested hashes into objects' do
      test = BaseTest.new({
        'id' =>   14,
        'name' => 'test!',
        'clients' => [
          {
            'id' =>   15,
            'name' => 'nested'
          }
        ]
      })
      test.clients.should be_instance_of Array
      test.clients.length.should == 1
      test.clients.each do |client|
        client.should be_instance_of Tickspot::Client
      end
    end
  end
  
  describe '#id' do
    it 'should return the "id" attribute' do
      @test.id.should == 14
    end
  end
  
  describe '.all' do    
    it 'should send a request' do
      Tickspot::Request.should_receive(:post).with(
        :section => :tests
      )
      BaseTest.all
    end
    
    it 'should pass the arguments' do
      Tickspot::Request.should_receive(:post).with(
        :section => :tests,
        :project_id => 14
      )
      BaseTest.all(:project_id => 14)
    end
    
    it 'should return BaseTest objects' do
      Tickspot::Request.stub!(:post).and_return([{:id => 123}])
      BaseTest.all.first.should be_instance_of BaseTest      
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

describe Tickspot::CreateEntry do
  it 'should have :create_entry as its section' do
    Tickspot::CreateEntry.section.should == :create_entry
  end
end

describe Tickspot::UpdateEntry do
  it 'should have :update_entry as its section' do
    Tickspot::UpdateEntry.section.should == :update_entry
  end
end
