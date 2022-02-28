# require neccesary files
require "colorize"
require_relative "player"
require_relative "pokemon"
require_relative "pokedex/pokemons"
require_relative "battle"

class Game
  include Pokedex

  attr_reader :fight_commands
  attr_accessor :player, :bot, :gym_leader

  def start
    @commands = ["Stats", "Train", "Leader", "Exit"]
    @fight_commands = ["Fight", "fight", "Leave", "leave"]
    header
    intro
    getplayername
    select_pokemon

    # Suggested game flow
    action = menu
    until action == "Exit"
      case action
      when "Train"
        train
        action = menu
      when "Leader"
        challenge_leader
        action = menu
      when "Stats"
        show_stats
        action = menu
      end
    end

    goodbye
  end

  # The intro header for the game
  def header
    puts ("$#" * 30).colorize(color: :black, background: :red)
    puts (("$#" * 7) + ("  " * 16) + ("$#" * 7)).colorize(color: :black, background: :red)
    puts ("\#$#\#$#\#$#\#$ ---#{' ' * 9}Pokemon Ruby#{' ' * 9}--- \#$#\#$#\#$\#$#").colorize(
      color: :black, background: :red
    )
    puts (("$#" * 7) + ("  " * 16) + ("$#" * 7)).colorize(color: :black, background: :red)
    puts ("#{'$#' * 30}\n").colorize(color: :black, background: :red)
  end

  def intro
    puts "\nHello there! Welcome to the world of POKEMON! My name is OAK!\nPeople call me the POKEMON PROF!"
    puts "\nThis world is inhabited by creatures called POKEMON! For some\npeople, POKEMON are pets. Others use them for fights. Myself...\nI study POKEMON as a profession."
  end

  # Internal Class method to get the player's name and initialize the player instance.
  def getplayername
    print "\nFirst, what is your name?\n> ".colorize(:yellow)
    player_name = gets.chomp.capitalize
    while player_name.empty?
      print "You have to enter your name! Try again:\n> "
      player_name = gets.chomp
    end
    @player = Player.new(player_name)
    puts "Right so your name is #{@player.name.upcase.colorize(:yellow)}!"
  end

  # Internal Class method to get the players pokemon
  def new_pokemon_info
    opt1 = "Bulbasaur" # Starting options handled separately
    opt2 = "Charmander"
    opt3 = "Squirtle"
    puts "\nYour very own POKEMON legend is about to unfold! A world of\ndreams and adventures with POKEMON awaits! Let's go!\nHere, #{@player.name.upcase.colorize(:yellow)}! There are 3 POKEMON here! Haha!"
    puts "When I was young, I was a serious POKEMON trainer.\nIn my old age, I have only 3 left, but you can have one! Choose!\n"
    print "\n1. #{Pokedex::POKEMONS[opt1][:species].colorize(:green)}    2. #{Pokedex::POKEMONS[opt2][:species].colorize(:red)}    3. #{Pokedex::POKEMONS[opt3][:species].colorize(:light_blue)}\n> "
    pokemon_choice = gets.chomp.capitalize
    until [opt1, opt2, opt3].include?(pokemon_choice)
      print "You can only choose among these 3! Try again:\n> "
      pokemon_choice = gets.chomp.capitalize
    end
    puts "\nYou selected #{Pokedex::POKEMONS[pokemon_choice][:species].upcase.colorize(:yellow)}. Great choice!"
    print "Give your pokemon a name?\n> "
    poke_name = gets.chomp.capitalize
    poke_name = Pokedex::POKEMONS[pokemon_choice][:species] if poke_name.empty?
    puts "#{@player.name.upcase.colorize(:yellow)}, raise your young #{poke_name.upcase.colorize(:yellow)} by making it fight"
    puts "When you feel readt you can challenge BROCK, the PEWTER's GYM LEADER"
    [pokemon_choice, poke_name]
  end

  # Generate player's pokemon
  def select_pokemon
    choice, name = new_pokemon_info
    @player.give_pokemon(choice, name, level = 1)
  end

  def train
    av_pokemons = Pokedex::POKEMONS.keys
    name = av_pokemons[rand(0..av_pokemons.length - 1)]
    bot_level = 0
    bot_level = @player.my_pokemon.level + rand(-1..2) until bot_level.positive?

    train_bot = Bot.new
    train_bot.give_pokemon(name, name, bot_level)

    puts "#{player.name.upcase.colorize(:yellow)} challenge #{train_bot.name.colorize(:red)} for training"
    puts "#{train_bot.name.colorize(:red)} has a #{train_bot.my_pokemon.species.colorize(:red)} level #{train_bot.my_pokemon.level.to_s.colorize(:light_red)}"
    puts "What do you want to do now?"
    puts "\n1. Fight        2.Leave"
    action = fight_action
    if action == "Fight"
      new_battle = Battle.new(@player, train_bot)
      new_battle.start
    else
      system("clear")
    end
    train_bot = nil
  end

  def challenge_leader
    name = "Brock"
    gym_leader = Bot.new(name)
    level = 10
    gym_leader.give_pokemon("Onix", "Onix", level)
    puts "#{player.name.upcase.colorize(:yellow)} challenge Gym Leader #{gym_leader.name.upcase.colorize(:red)} for a fight!"
    puts "#{gym_leader.name.colorize(:red)} has a #{gym_leader.my_pokemon.species.colorize(:red)} level #{gym_leader.my_pokemon.level.to_s.colorize(:light_red)}"
    puts "What do you want to do now?"
    puts "\n1. Fight        2.Leave"
    action = fight_action
    if action == "Fight"
      new_battle = Battle.new(@player, gym_leader)
      winner = new_battle.start
      if winner == @player.my_pokemon
        puts "Congratulations! You have won the game!\nYou can continue training your Pokemon if you want"
      end
    else
      system("clear")
    end
    gym_leader = nil
  end

  def show_stats
    system("clear")
    puts "#{player.my_pokemon.name}:".colorize(:yellow)
    puts "Kind: #{player.my_pokemon.species.colorize(:light_white)}"
    puts "Level: #{player.my_pokemon.level.to_s.colorize(:light_green)}"
    puts "Type: #{player.my_pokemon.type.join('/').capitalize.colorize(:light_white)}"
    puts "Stats:".colorize(:light_blue)
    puts "HP: #{player.my_pokemon.current_stats[:hp].to_s.colorize(:light_green)}"
    puts "Attack: #{player.my_pokemon.current_stats[:attack].to_s.colorize(:light_green)}"
    puts "Defense: #{player.my_pokemon.current_stats[:defense].to_s.colorize(:light_green)}"
    puts "Special Attack: #{player.my_pokemon.current_stats[:special_attack].to_s.colorize(:light_green)}"
    puts "Special Defense: #{player.my_pokemon.current_stats[:special_defense].to_s.colorize(:light_green)}"
    puts "Speed: #{player.my_pokemon.current_stats[:speed].to_s.colorize(:light_green)}"
    puts "Experience Points: #{player.my_pokemon.exp.to_s.colorize(:light_green)}"
  end

  def goodbye
    system("clear")
    puts "Thanks for playing Pokemon Ruby".colorize(background: :red, color: :light_white)
    puts "This game was created with love by: César, Diego, Enmanuel & Guillermo".colorize(background: :red,
                                                                                           color: :light_white)
  end

  def menu
    puts ("#{'-' * 26}Menu#{'-' * 26}").colorize(color: :black, background: :red)
    puts "\n1. Stats        2. Train        3. Leader       4. Exit".colorize(:light_red)
    action = getaction
  end

  def fight_action
    print "> "
    act = gets.chomp.capitalize
    puts
    until @fight_commands.include? act
      print "Invalid action, try again:\n> "
      act = gets.chomp.capitalize
      puts
    end
    act
  end

  def getaction
    print "> "
    act = gets.chomp.capitalize
    puts
    until @commands.include? act
      print "Invalid action, try again:\n> "
      act = gets.chomp.capitalize
      puts
    end
    system("clear")
    act
  end
end

game = Game.new
game.start
