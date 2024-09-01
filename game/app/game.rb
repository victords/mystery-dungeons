require 'app/player_character'
require 'app/scene'

class Game
  class << self
    def init
      @scenes = {}
      @scenes[1] = @scene = Scene.new(1)
      @player = PlayerCharacter.new
      entrance = @scene.entrances[0]
      @player.set_position(entrance[0], entrance[1])
      @player.on_exit = method(:on_player_exit)
    end

    def on_player_exit(exit_obj)
      dest_scene_id = exit_obj.dest_scene
      @scenes[dest_scene_id] ||= Scene.new(dest_scene_id)
      @scene = @scenes[dest_scene_id]
      entrance = @scene.entrances[exit_obj.dest_entrance]
      @player.set_position(entrance[0], entrance[1])
      @transitioning = true
    end

    def update
      @transitioning = false
      @scene.update
      @player.update(@scene)
    end

    def draw
      return if @transitioning
      
      @scene.draw
      @player.draw
    end
  end
end
