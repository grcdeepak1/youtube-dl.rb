require_relative '../test_helper'

TestKlass = Class.new do
  include YoutubeDL::Support

  def executable_path
    usable_executable_path_for 'youtube-dl'
  end
end

describe YoutubeDL::Support do
  before do
    @klass = TestKlass.new
  end

  describe '#usable_executable_path' do
    it 'should detect system executable' do
      vendor_bin = File.join(Dir.pwd, 'vendor', 'bin', 'youtube-dl')
      Dir.mktmpdir do |tmpdir|
        FileUtils.cp vendor_bin, tmpdir

        old_path = ENV["PATH"]
        ENV["PATH"] = "#{tmpdir}:#{old_path}"

        usable_path = @klass.usable_executable_path_for('youtube-dl')
        assert_match usable_path, "#{tmpdir}/youtube-dl"

        ENV["PATH"] = old_path
      end
    end

    it 'should not have a newline char in the executable_path' do
      assert_match /youtube-dl\z/, @klass.executable_path
    end
  end

  describe '#cocaine_line' do
    it 'should return a Cocaine::CommandLine instance' do
      assert_instance_of Cocaine::CommandLine, @klass.cocaine_line('')
    end

    it 'should be able to override the executable' do
      line = @klass.cocaine_line('hello', 'echo')
      assert_equal "echo hello", line.command
    end

    it 'should default to youtube-dl' do
      line = @klass.cocaine_line(@klass.quoted(TEST_URL))
      assert_includes line.command, "youtube-dl \"#{TEST_URL}\""
    end
  end

  describe '#quoted' do
    it 'should add quotes' do
      assert_equal "\"#{TEST_URL}\"", @klass.quoted(TEST_URL)
    end
  end
end
