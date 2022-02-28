# require neccesary files
require_relative 'pokedex/pokemons'
require_relative 'pokemon'

class Player
  attr_reader :name, :my_pokemon

  def initialize(name)
    @name = name
    @my_pokemon = nil
  end

  def give_pokemon(choice, name, level)
    @my_pokemon = Pokemon.new(choice, name, level)
  end

  def select_move(player_pokemon)
    move = gets.chomp.downcase
    until player_pokemon.moves.include? move
      print "Invalid move, try again:\n> "
      move = gets.chomp
      puts
    end
    move
  end
end

class Bot < Player
  def initialize(name = "Random Trainer")
    @name = name
  end

  def select_move(bot_pokemon)
    move = bot_pokemon.moves[rand(0..bot_pokemon.moves.length - 1)]
  end
end
# Create a class Bot that inherits from Player and override the select_move method
