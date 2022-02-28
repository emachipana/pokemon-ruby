# require neccesary files

require_relative "player"
require_relative "pokemon"
require_relative "pokedex/pokemons"
require_relative "battle"

class Game

  include Pokedex

  attr_reader :fight_commands
  attr_accessor :player, :bot, :gym_leader

  def start
    @commands = %w[Stats Train Leader Exit]
    @fight_commands = %w[Fight fight Leave leave]
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

  def header #The intro header for the game
    puts "$#" * 30
    puts ("$#" * 7) + ("  " * 16) + ("$#" * 7)
    puts ("#$##$##$##$ ---" ) + (" " * 9) + ("Pokemon Ruby") + (" " * 9) + ("--- #$##$##$#$#")
    puts ("$#" * 7) + ("  " * 16) + ("$#" * 7)
    puts "$#" * 30 + "\n"
  end

  def intro
    puts "\nHello there! Welcome to the world of POKEMON! My name is OAK!\nPeople call me the POKEMON PROF!"
    puts "\nThis world is inhabited by creatures called POKEMON! For some\npeople, POKEMON are pets. Others use them for fights. Myself...\nI study POKEMON as a profession."
  end

  def getplayername                        #Internal Class method to get the player's name and initialize the player instance.
    print "\nFirst, what is your name?\n> "
    player_name = gets.chomp.capitalize
    while player_name.empty?
      print "You have to enter your name! Try again:\n> "
      player_name = gets.chomp
    end
    @player = Player.new(player_name)
    puts "Right so your name is #{@player.name.upcase}!"
  end

  def new_pokemon_info            # Internal Class method to get the players pokemon
    opt1 = "Bulbasaur"      # Starting options handled separately
    opt2 = "Charmander"
    opt3 = "Squirtle"
  puts "\nYour very own POKEMON legend is about to unfold! A world of\ndreams and adventures with POKEMON awaits! Let's go!\nHere, #{@player.name.upcase}! There are 3 POKEMON here! Haha!"
  puts "When I was young, I was a serious POKEMON trainer.\nIn my old age, I have only 3 left, but you can have one! Choose!\n"
  print "\n1. #{Pokedex::POKEMONS[opt1][:species]}    2. #{Pokedex::POKEMONS[opt2][:species]}    3. #{Pokedex::POKEMONS[opt3][:species]}\n> "
  pokemon_choice = gets.chomp
    until [opt1,opt2,opt3].include? (pokemon_choice)
      print "You can only choose among these 3! Try again:\n> "
      pokemon_choice = gets.chomp
    end
    puts "\nYou selected #{Pokedex::POKEMONS[pokemon_choice][:species].upcase}. Great choice!"
    print "Give your pokemon a name?\n> "
    poke_name = gets.chomp.capitalize
    poke_name = Pokedex::POKEMONS[pokemon_choice][:species] if poke_name.empty?
    puts "#{@player.name.upcase}, raise your young #{poke_name.upcase} by making it fight"
    puts "When you feel readt you can challenge BROCK, the PEWTER's GYM LEADER"  
    [pokemon_choice, poke_name]
  end

  def select_pokemon        # Generate player's pokemon
    choice, name = new_pokemon_info
    @player.give_pokemon(choice, name, level = 1)
  end

  def train
    av_pokemons = Pokedex::POKEMONS.keys
    name = av_pokemons[rand(0..av_pokemons.length - 1)]
    bot_level = 0
    until bot_level.positive?
      bot_level = @player.my_pokemon.level + rand(-1..2)
    end

    train_bot = Bot.new
    train_bot.give_pokemon(name, name, bot_level)
  
    puts "#{player.name} challenge #{train_bot.name} for training"
    puts "#{train_bot.name} has a #{train_bot.my_pokemon.species} level #{train_bot.my_pokemon.level}"
    puts "What do you want to do now?"
    puts "\n1. Fight        2.Leave"
    action = fight_action
    if action == "Fight" || action == "fight"
      new_battle = Battle.new(@player, train_bot)
      new_battle.start
    else
    end
    train_bot = nil
  end

  def challenge_leader
    gym_leader = Bot.new("Brock")
    level = 10
    gym_leader.give_pokemon("Onix", "Onix", level)
    puts "#{player.name} challenge Gym Leader #{gym_leader.name} for a fight!"
    puts "#{gym_leader.name} has a #{gym_leader.my_pokemon.species} level #{gym_leader.my_pokemon.level}"
    puts "What do you want to do now?"
    puts "\n1. Fight        2.Leave"
    action = fight_action
    if action == "Fight" || action == "fight"
      new_battle = Battle.new(@player, gym_leader)
      winner = new_battle.start
      puts "Congratulation! You have won the game!\nYou can continue training your Pokemon if you want" if winner == @player.my_pokemon
    else
    end
    gym_leader = nil
  end

  def show_stats
    system("clear")
    puts "#{player.my_pokemon.name}:"
    puts "Kind: #{player.my_pokemon.species}"
    puts "Level: #{player.my_pokemon.level}"
    puts "Type: #{player.my_pokemon.type.join("/").to_s}"
    puts "Stats:"
    puts "HP: #{player.my_pokemon.current_stats[:hp]}"
    puts "Attack: #{player.my_pokemon.current_stats[:attack]}"
    puts "Defense: #{player.my_pokemon.current_stats[:defense]}"
    puts "Special Attack: #{player.my_pokemon.current_stats[:special_attack]}"
    puts "Special Defense: #{player.my_pokemon.current_stats[:special_defense]}"
    puts "Speed: #{player.my_pokemon.current_stats[:speed]}"
    puts "Experience Points: #{player.my_pokemon.exp}"
  end

  def goodbye
    system("clear")
    puts "Thanks for playing Pokemon Ruby"
    puts "This game was created with love by: César, Diego, Enmanuel & Guillermo"
  end

  def menu
    puts ("-" * 26) + ("Menu") + ("-" * 26)
    puts "\n1. Stats        2. Train        3. Leader       4. Exit"
    action = getaction
  end

  def fight_action
    print "> "
    act = gets.chomp
    puts
    until @fight_commands.include? act
      print "Invalid action, try again:\n> "
      act = gets.chomp
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
      act = gets.chomp
      puts
    end
    act
  end

end

game = Game.new
game.start
