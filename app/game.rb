require 'app/player_character'
require 'app/scene'

class Game
  class << self
    def init
      @scene = Scene.new(1)
      @player = PlayerCharacter.new
      entrance = @scene.entrances[0]
      @player.set_position(entrance[0], entrance[1])
    end

    def update
      @player.update(@scene)
    end

    def draw
      @scene.draw
      @player.draw
    end
  end
end
