require 'helper'

describe Gamebox::Configuration do
  describe ".add_setting" do
    it 'can add custom settings' do
      described_class.add_setting :foopy

      subject.foopy.should_not be
      subject.foopy?.should_not be
      subject.foopy = :yep
      subject.foopy.should == :yep
    end
  end

  describe "gamebox settings" do
    it 'has all the settings' do
      [ :config_path,
        :data_path,
        :music_path,
        :sound_path,
        :gfx_path,
        :fonts_path,
        :gb_config_path,
        :gb_data_path,
        :gb_music_path,
        :gb_sound_path,
        :gb_gfx_path,
        :gb_fonts_path,
        :game_name, 
        :needs_cursor,
        :stages ].each do |setting|
        subject.should respond_to(setting)
      end
    end

    describe "game_name" do
      it 'has default value' do
        subject.game_name.should == "Untitled Game"
      end
    end

    describe "needs_cursor" do
      it 'has default value' do
        subject.needs_cursor.should be_false
      end
    end

    describe "stages" do
      it 'has default value' do
        subject.stages.should == [:demo]
      end
    end
  end

end
