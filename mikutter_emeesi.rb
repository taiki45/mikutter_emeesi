# -*- coding: utf-8 -*-
require "socket"

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
end
