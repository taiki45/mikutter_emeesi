# -*- coding: utf-8 -*-
require 'socket'
require 'json'

Plugin.create :mikutter_emeesi do
  config_path = File.expand_path('../config', __FILE__)
  port = File.exist?(config_path) ? open(config_path).read.chomp.to_i : 45678

  Thread.new do
    server = TCPServer.open(port)
    loop do
      Thread.start(server.accept) do |s|
        Service.primary.update(message: s.read)
        s.close
      end
    end
  end

  command(
    :mac_reply,
    name: 'reply in other window',
    condition: -> _ { true },
    visible: true,
    role: :timeline
  ) do |opt|
    Thread.new do
      msg = opt.messages.first
      socket = TCPSocket.new('localhost', port + 1)
      socket.write(JSON.generate({
        'screen_name' => msg.user.idname,
        'status_id' => msg.id,
        'message' => msg[:message]
      }))
      res = socket.gets
      Service.primary.update(message: res, replyto: msg)
      socket.close
    end
  end
end
