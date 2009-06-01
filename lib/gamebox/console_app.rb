puts "Connecting to game..."
require 'drb'
DRb.start_service
@game = DRbObject.new nil, "druby://localhost:7373"

#irb @game
