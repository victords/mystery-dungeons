require 'app/player_character'
require 'app/scene'

class Game
  class << self
    def init
      @scene = Scene.new
      @player = PlayerCharacter.new
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
