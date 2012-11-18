require 'spec_helper'

describe CobolData::Base do
  before(:all) do
    class Account < CobolData::Base
      self.schema_file = File.join(File.dirname(__FILE__), '..', 'fixtures', 'accounts_schema.txt')
      self.data_file   = File.join(File.dirname(__FILE__), '..', 'fixtures', 'accounts_data.txt')
    end
  end

  context 'instantiating from hash' do
    let(:account) { Account.new firstname: 'Marissa', lastname: 'Mayer', accountnumber: 1861 }

    it 'has attributes' do
      account.firstname.should == 'Marissa'
      account.lastname.should == 'Mayer'
      account.accountnumber.should == 1861
    end

    it 'has setters' do
      account.firstname = 'Melissa'
      account.firstname.should == 'Melissa'
    end

  end

  context 'reading from file' do
    let(:account) { Account.first }

    it 'reads accounts from a file' do
      account.firstname.should == 'DENNIS    '
      account.lastname.should == 'RITCHIE   '
      account.accountnumber.should == 1
    end
  end

  context 'writing to file' do
    let(:account) { Account.new firstname: 'Jack', lastname: 'Dorsey    ', accountnumber: 12648 }

    it 'writes to a file' do
      file_handle = mock('FILE')
      file_handle.should_receive(:write).with("Jack      Dorsey    12648\n")
      File.should_receive(:open).with(Account.data_file, "a").and_yield file_handle

      account.save
    end
  end

end
