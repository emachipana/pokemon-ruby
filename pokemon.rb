# require neccesary files

require_relative "pokedex/pokemons"
require_relative "pokedex/moves"

module Stats_mechanics
  def gen_new_stats
    @current_stats[:hp] = ((2 * @base_stats[:hp] + @ind_values[:hp] + (@effort_values[:hp]/4).floor) * @level / 100 + @level + 10).floor
    @current_stats[:attack] = ((2 * @base_stats[:attack] + @ind_values[:attack] + (@effort_values[:attack]/4).floor) * @level / 100 + 5).floor
    @current_stats[:defense] = ((2 * @base_stats[:defense] + @ind_values[:defense] + (@effort_values[:defense]/4).floor) * @level / 100 + 5).floor
    @current_stats[:special_attack] = ((2 * @base_stats[:special_attack] + @ind_values[:special_attack] + (@effort_values[:special_attack]/4).floor) * @level / 100 + 5).floor
    @current_stats[:special_defense] = ((2 * @base_stats[:special_defense] + @ind_values[:special_defense] + (@effort_values[:special_defense]/4).floor) * @level / 100 + 5).floor
    @current_stats[:speed] = ((2 * @base_stats[:speed] + @ind_values[:speed] + (@effort_values[:speed]/4).floor) * @level / 100 + 5).floor
  end
end

class Pokemon
  include Stats_mechanics

  attr_reader :species, :type, :growth_rate, :moves, :ind_values, :base_exp
  attr_accessor :name, :exp, :effort_values, :effort_points, :base_stats, :level, :current_stats, :current_hp, :current_move

  def initialize(choice, name, level)
    poke = Pokedex::POKEMONS[choice]

    @name = name
    @species = poke[:species]
    @type = poke[:type]
    @exp = 0
    @level = level
    @growth_rate = poke[:growth_rate]
    @effort_points = poke[:effort_points]
    @base_stats = poke[:base_stats]
    @base_exp = poke[:base_exp]
    @current_stats = {}
    @moves = poke[:moves]

    values_gen = Array.new(6) { rand(0..31) }
    keys = @base_stats.keys
    @ind_values = Hash[keys.zip(values_gen)]

    values_gen = Array.new(6) {0}
    @effort_values = Hash[keys.zip(values_gen)]

    set_exp
    gen_new_stats

  end

  def prepare_for_battle
    @current_hp = @current_stats[:hp]
  end

  def receive_damage(damage)
    @current_hp -= damage
    @current_hp = @current_hp.clamp(0, @current_stats[:hp])
  end

  def set_current_move(move)
    @current_move = Pokedex::MOVES.select { |key, value| key == move}
    @current_move = @current_move[move]
  end

  def fainted?
    @current_hp.zero?
  end

  def attack(target)
    puts "#{@name.upcase.colorize(:yellow)} used #{@current_move[:name].upcase.colorize(:light_red)}"
    # Accuracy check
    hit = accuracy_check
    if hit                          # If the movement is not missed
      damage = damage_amount(target)
      if critical_hit
        damage *= 1.5
        puts "It was a CRITICAL hit!".colorize(color: :light_white, background: :red)
      end
      effectiveness = hit_effectiveness(target)
      if effectiveness <= 0.5
        puts "It's not very effective...".colorize(color: :black, background: :light_white)
      elsif effectiveness >= 1.5
        puts "It's super effective!".colorize(color: :light_yellow, background: :red)
      end
      damage *= effectiveness
      damage = damage.round
      target.receive_damage(damage)
      puts "And it hit #{target.name.upcase.colorize(:light_yellow)} with #{damage.to_s.colorize(:light_red)} damage!"
    else
      puts "But it MISSED!".colorize(background: :light_black, color: :red)
    end
  end

  def set_exp
    if @level == 1
      @exp = 0
    else
      case @growth_rate
      when :slow
        @exp = ((5 * (@level)**3) / 4.0).floor
      when :medium_slow
        @exp = (6 / 5.0 * (@level)**3 - 15 * (@level)**2 + 100 * (@level) - 140).floor
      when :medium_fast
        @exp = ((@level)**3).floor
      when :fast
        @exp = (4 * (@level)**3 / 5.0).floor
      end
    end
  end

  def levelup(exp_gained)
    case @growth_rate
    when :slow
      next_level_exp = ((5 * (@level + 1)**3) / 4.0).floor
    when :medium_slow
      next_level_exp = (6 / 5.0 * (@level + 1)**3 - 15 * (@level + 1)**2 + 100 * (@level + 1) - 140).floor
    when :medium_fast
      next_level_exp = ((@level + 1)**3).floor
    when :fast
      next_level_exp = (4 * (@level + 1)**3 / 5.0).floor
    end
    @exp += exp_gained
    if @exp >= next_level_exp
      @level += 1
      puts "#{@name.upcase.colorize(:yellow)} reached level #{@level.to_s.colorize(:green)}!\n"
    end
  end

  def increase_stats(target)
    exp_gained = (target.base_exp * target.level/ 7.00).floor
    puts "#{@name.upcase.colorize(:yellow)} gained #{exp_gained.to_s.colorize(:green)} experience points"
    levelup(exp_gained)

    new_effort_point_name = target.effort_points[:type]
    new_effort_point_value = target.effort_points[:amount]
    @effort_values[new_effort_point_name] += new_effort_point_value
    gen_new_stats
  end

  # private methods:
  def accuracy_check
    hit = @current_move[:accuracy] >= rand(0..100) ? true : false
  end

  def critical_hit
    true if 1 == rand(1..16)
  end

  def hit_effectiveness(target)
    amount = Pokedex::TYPE_MULTIPLIER.select { |value| value[:user] == @current_move[:type] }
    # verify
    amount.select! { |value| target.type.any?(value[:target]) }
    multiplier = 1
    if amount.empty? == false
      amount.each do |value|
        multiplier *= value[:multiplier]
      end
    end
    multiplier
  end

  def damage_amount(target)
    special_moves = Pokedex::SPECIAL_MOVE_TYPE
    if special_moves.include?(@current_move[:type]) then offensive_stat = @current_stats[:special_attack] else offensive_stat = @current_stats[:attack] end
    if special_moves.include?(@current_move[:type]) then target_defensive_stat = target.current_stats[:special_defense] else target_defensive_stat = target.current_stats[:defense] end
    damage = (((2 * level / 5.0 * 2).floor * offensive_stat * @current_move[:power] / target_defensive_stat).floor / 50.0).floor + 2
  end
end
