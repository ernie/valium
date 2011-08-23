require 'spec_helper'

describe Valium do

  context 'with a symbol key' do
    subject { Person[:id] }
    it { should have(1000).ids }
    it { should eq((1..1000).to_a) }
  end

  context 'with a string key' do
    subject { Person['id'] }
    it { should have(1000).ids }
    it { should eq((1..1000).to_a) }
  end

  context 'with multiple keys' do
    subject { Person[:id, :last_name] }
    it { should have(1000).elements }
    it { should eq((1..1000).map {|n| [n, "Number#{n}"]})}
  end

  context 'with a datetime column' do
    subject { Person[:created_at] }
    it { should have(1000).datetimes }
    it { should be_all {|d| Time === d}}
  end

  context 'with a serialized column' do
    subject { Person[:extra_info] }
    it { should have(1000).hashes }
    it { should eq 1.upto(1000).map {|n| {:a_key => "Value Number #{n}"} }}
  end

  context 'with a scope' do
    subject { Person.where(:id => [1,500,1000])[:last_name] }
    it { should have(3).last_names }
    it { should eq ['Number1', 'Number500', 'Number1000'] }
  end

  context 'with a scope and multiple keys' do
    subject { Person.where(:id => [1,500,1000])[:last_name, :id, :extra_info] }
    it { should have(3).elements }
    it { should eq [1,500,1000].map {|n| ["Number#{n}", n, {:a_key => "Value Number #{n}"}]}}
  end

  context 'with a relation array index' do
    subject { Person.where(:id => [1,500,1000])[1] }
    it { should eq Person.find(500) }
  end

  context 'with a relation array start and length' do
    subject { Person.where(:id => 1..20)[10,3] }
    it { should have(3).people }
    it { should eq Person.offset(10).limit(3) }
  end

  context 'with a relation array range' do
    subject { Person.where(:id => 1..20)[0..9] }
    it { should have(10).people }
    it { should eq Person.first(10) }
  end

end