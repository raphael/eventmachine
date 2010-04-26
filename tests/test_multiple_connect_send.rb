require 'rubygems'
require 'eventmachine'
require 'test/unit'

class TestMultipleConnectSend < Test::Unit::TestCase

  SOCKET_PORT = 55555

  class CommandSerializer
    SEPARATOR = "\n#!!!\n"

    def self.dump(command)
      data = YAML::dump(command)
      data += SEPARATOR
    end

    def self.load(data)
      command = YAML::load(data) rescue nil
      raise "Invalid serialized command:\n#{data}" unless command
      command
    end
  end

  class CommandParser
    def initialize &block
      raise 'Missing handler block' unless block
      @callback = block
      @buildup = ''
    end

    def parse_chunk(chunk)
      @buildup << chunk
      chunks = @buildup.split(CommandSerializer::SEPARATOR, -1)
      if do_call = chunks.size > 1
        commands = []
        commands << CommandSerializer.load(@buildup)
        (1..chunks.size - 2).each { |i| commands << CommandSerializer.load(chunks[i]) }
        commands.each { |cmd| EM.next_tick { @callback.call(cmd) } }
        @buildup = chunks.last
      end
      do_call
    end
  end

  class Server
    module InputHandler
      def initialize(handler)
        @handler = handler
        @parser = CommandParser.new { |cmd| handler.call(cmd, self) }
      end

      def receive_data(data)
        @parser.parse_chunk(data)
        true
      end
    end

    def self.listening
      !@conn.nil?
    end

    def self.listen &block
      raise 'Missing listener block' unless block_given?
      raise 'Already listening' if listening
      begin
        @conn = EM.start_server('127.0.0.1', SOCKET_PORT, InputHandler, block)
      rescue Exception => e
        puts("Could not start commands listener: #{e.message}")
      end
      true
    end

    def self.stop_listening
      res = !@conn.nil?
      if res
        EM.stop_server(@conn)
        @conn = nil
      end
      res
    end

    def self.reply(conn, data)
      conn.send_data(CommandSerializer.dump(data))
      conn.close_connection_after_writing
      true
    end
  end

  module Client
    module OutputHandler
      def initialize(input)
        @input = input
       end
      def post_init
        send_data(CommandSerializer.dump(@input))
        close_connection_after_writing
      end
    end

    def self.send_input(input)
      EM.connect('127.0.0.1', SOCKET_PORT, OutputHandler, input)
    end
  end

  def stop
    Server.stop_listening
    EM.stop
  end

  def run_test(count)
    @inputs = []
    EM.run do
      Server.listen do |input, _|
        @inputs << input
        stop if input == 'final'
      end
      count.times do |i|
        Client.send_input("input#{i+1}")
      end
      Client.send_input("final")
      EM.add_timer(2) { stop }
    end

    assert_equal(count + 1, @inputs.size)
    count.times do |i|
      assert_equal("input#{i+1}", @inputs[i])
    end
    assert_equal('final', @inputs[count])
  end

  def test_connect_send_1
    # the initial test succeeds
    run_test(1)
  end

  def test_connect_send_10
    # the subsequent test fails because the windows version of eventmachine
    # fails to close the listener socket from the first run and the second
    # listener never gets the connection notifications (they are presumably
    # being stolen by the first listener which is still open but in a bad state).
    run_test(10)
  end
end
