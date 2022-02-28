class Battle

  def initialize(player, bot)
    @player = player
    @bot = bot
    @player_pokemon = @player.my_pokemon 
    @bot_pokemon = @bot.my_pokemon
  end

  def start
    # Prepare the Battle (print messages and prepare pokemons)
    system("clear")
    puts "#{@bot.name.upcase.colorize(:red)} sent out #{@bot_pokemon.name.upcase.colorize(:red)}!"
    puts "#{@player.name.upcase.colorize(:yellow)} sent out #{@player_pokemon.name.upcase.colorize(:yellow)}!"
    @player_pokemon.prepare_for_battle
    @bot_pokemon.prepare_for_battle
    puts (("-" * 19) + "Battle Start!" + ("-" * 19)).colorize(:red)
    # Until one pokemon faints
    until @player_pokemon.fainted? || @bot_pokemon.fainted?
      battle_status   # --Print Battle Status
      ask_move
      user_move = @player.select_move(@player_pokemon)
      system("clear")
      user_move = @player_pokemon.set_current_move(user_move)
      
      bot_move = @bot.select_move(@bot_pokemon)
      bot_move = @bot_pokemon.set_current_move(bot_move)
      first_move, second_move = order(user_move, bot_move)

      @fighter1.set_current_move(first_move[:name])
      puts ("-" * 50).colorize(:light_white)
      @fighter1.attack(@fighter2)
      break if @fighter2.fainted?

      @fighter2.set_current_move(second_move[:name])
      puts ("-" * 50).colorize(:light_white)
      @fighter2.attack(@fighter1) 
      puts ("-" * 50).colorize(:light_white)
    end                                                    # Check which player won and print messages
    winner = @fighter1.fainted? ? @fighter2 : @fighter1
    loser = @fighter1.fainted? ? @fighter1 : @fighter2
    puts "#{loser.name.upcase} fainted!".colorize(background: :light_black, color: :light_white) # --If first is fainted, print fainted message
    puts "-" * 50
    puts "#{winner.name.upcase} WINS!\n".colorize(background: :light_white, color: :red )

    @player_pokemon.increase_stats(@bot_pokemon) if winner == @player_pokemon # If the winner is the Player increase pokemon stats
 
    winner
  end

  def battle_status
    puts "#{@player.name}'s #{@player_pokemon.name} - Level #{@player_pokemon.level}"
    puts "HP: #{@player_pokemon.current_hp.to_s.colorize(:light_green)}"
    puts "#{@bot.name}'s #{@bot_pokemon.name} - Level #{@bot_pokemon.level}"
    puts "HP: #{@bot_pokemon.current_hp.to_s.colorize(:light_green)}"
  end

  def ask_move
    puts "\n#{@player.name.upcase.colorize(:yellow)}, select your move: "
    puts
    @player_pokemon.moves.each_with_index do |move, index|
      print "#{index + 1}. #{move}     "
    end
    puts
    print "> "
  end

  def order(user_move, bot_move)
    if user_move[:priority] > bot_move[:priority]
      @fighter1 = @player_pokemon
      first_move = user_move
      @fighter2 = @bot_pokemon
      second_move = bot_move
    elsif user_move[:priority] < bot_move[:priority]
      @fighter1 = @bot_pokemon
      first_move = bot_move
      @fighter2 = @player_pokemon
      second_move = user_move
    else
      if @player_pokemon.current_stats[:speed] > @bot_pokemon.current_stats[:speed]
        @fighter1 = @player_pokemon
        first_move = user_move
        @fighter2 = @bot_pokemon
        second_move = bot_move
      elsif @player_pokemon.current_stats[:speed] < @bot_pokemon.current_stats[:speed]
        @fighter1 = @bot_pokemon
        first_move = bot_move
        @fighter2 = @player_pokemon
        second_move = user_move
      else
        players = [@player_pokemon, @bot_pokemon]
        @fighter1 = players.shuffle[rand(0..1)]
        first_move = user_move if @fighter1 == @player_pokemon
        first_move = bot_move if @fighter1 == @bot_pokemon
        @fighter2 = players.select { |player| player != @fighter1 }
        @fighter2 = @fighter2[0]
        second_move = user_move if @fighter2 == @player_pokemon
        second_move = bot_move if @fighter2 == @bot_pokemon
      end
    end
    [first_move, second_move]
  end

end
