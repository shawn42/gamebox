require File.join(File.dirname(__FILE__),'helper')
require 'resource_manager'

describe 'A new resource manager' do
  before do
    @res_man = ResourceManager.new
  end

  it 'should be alive' do
    path = "foopy"
    surf = "yo"
    @res_man.should_receive(:load_image).with(path).and_return(surf)
    @res_man.load_image "foopy"
  end

end
