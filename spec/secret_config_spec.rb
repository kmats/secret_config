require 'spec_helper'

describe SecretConfig do
  it 'should have a version number' do
    SecretConfig::VERSION.should_not be_nil
  end

  it 'should load decompressed source' do
    Secret1.load!.should be_kind_of Hash
  end

  it 'should load compressed source' do
    Secret2.load!('hogehoge').should be_kind_of Hash
  end
end
