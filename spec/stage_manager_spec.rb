require File.join(File.dirname(__FILE__),'helper')

describe StageManager do
  inject_mocks :input_manager, :config_manager, :backstage,
    :this_object_context

  class FooStage; end
  class BarStage; end

  let(:foo_stage) { stub('foo stage', when: nil, curtain_raising: nil, curtain_dropping: nil) }
  let(:bar_stage) { stub('bar stage', when: nil, curtain_raising: nil, curtain_dropping: nil) }
  let(:foo_stage_config) { {foo: {thing:1} } }
  let(:bar_stage_config) { {bar: {thing:2} } }
  let(:stage_config) { {stages: [foo_stage_config, bar_stage_config]} }
  before do
    @input_manager.stubs(:clear_hooks)
    @config_manager.stubs(:load_config).returns(stage_config)

    # TODO sub context helper
    @subcontext = stub('subcontext')
    @subcontext.stubs(:[]).with('foo_stage').returns(foo_stage)
    @subcontext.stubs(:[]).with('bar_stage').returns(bar_stage)
    foo_stage.stubs(:configure).with(@backstage, {thing:1})
    bar_stage.stubs(:configure).with(@backstage, {thing:2})
    @this_object_context.stubs(:in_subcontext).yields(@subcontext)
  end

  describe '#setup' do
    it 'constructs' do
      subject.should be
    end

    it 'sets up the stage config' do
      subject.stage_names.should == [:foo, :bar]
      subject.stage_opts.should == [{thing:1}, {thing:2}]
    end
  end

  describe "#switch_to_stage" do

    it 'activates the new stage' do
      subject.switch_to_stage :foo, :args
      subject.current_stage.should == foo_stage
    end

    it 'raises the curtain on the new stage' do
      foo_stage.expects(:curtain_raising).with(:args)
      subject.switch_to_stage :foo, :args
    end

    it 'shuts down the current stage' do
      foo_stage.expects(:curtain_dropping).with(:other_args)
      @input_manager.expects(:clear_hooks).with(foo_stage)
      subject.switch_to_stage :foo, :args
      subject.switch_to_stage :bar, :other_args
    end
  end

  describe '#prev_stage' do
    it 'goes to prev stage' do
      subject.switch_to_stage :bar
      foo_stage.expects(:curtain_raising).with(:args)

      subject.prev_stage :args
      subject.current_stage.should == foo_stage
    end

    it 'exits on prev_stage of first stage' do
      subject.switch_to_stage :foo
      lambda { subject.prev_stage :args }.should raise_exception(SystemExit)
    end
  end

  describe '#next_stage' do
    it 'goes to next stage' do
      subject.switch_to_stage :foo
      bar_stage.expects(:curtain_raising).with(:args)

      subject.next_stage :args
      subject.current_stage.should == bar_stage
    end

    it 'exits on next_stage of last stage' do
      subject.switch_to_stage :bar
      lambda { subject.next_stage :args }.should raise_exception(SystemExit)
    end
  end

  describe '#restart_stage' do
    it 'restarts the current stage' do
      subject.switch_to_stage :foo, :args

      foo_stage.expects(:curtain_raising).with(:other_args)
      subject.restart_stage :other_args
    end
  end

  describe "#update" do
    it 'can be called on nil stage' do
      subject.update :target
    end

    it 'updates the current stage' do
      subject.switch_to_stage :foo, :args
      foo_stage.expects(:update).with(44)

      subject.update 44
    end
  end

  describe "#draw" do
    it 'can be called on nil stage' do
      subject.draw :target
    end

    it 'draws the current stage' do
      subject.switch_to_stage :foo, :args
      foo_stage.expects(:draw).with(:target)

      subject.draw :target
    end
  end

  describe 'callbacks' do
    it 'registers next_stage'
    it 'registers prev_stage'
    it 'registers restart_stage'
    it 'registers change_stage'
  end
end
