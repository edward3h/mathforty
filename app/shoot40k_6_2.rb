require 'logger'
require_relative 'stats'

module Shoot40k

class NullLogger < Logger
  def initialize(*args)
  end

  def add(*args, &block)
  end
end

@@logger = NullLogger.new

def self.logger
    @@logger
end

def self.logger=(l)
    @@logger = l || NullLogger.new
end

$template_hits = 4
$blast_hits = 2
$large_blast_hits = 5

class Dice
    def self.d6
        Proc.new { rand(6) + 1 }
    end

    def self.two_d6
        Proc.new { rand(6) + rand(6) + 2 }
    end

    def self.d3
        Proc.new { rand(3) + 1 }
    end
end

class Charts
    def self.shoot_hit?(bs, roll_provider = Dice.d6, reroll = false)
        if(bs < 6 || reroll)
            roll_provider.call > (6 - bs) || (reroll && Charts.shoot_hit?([bs, 5].max, roll_provider, false))
        else
            roll_provider.call > 1 || roll_provider.call > (11 - bs)
        end
    end

    def self.wound?(s, t, roll_provider = Dice.d6, reroll = false)
        d = s - t
        if(d >= 2)
            target = 2
        elsif(d == 1)
            target = 3
        elsif(d == 0)
            target = 4
        elsif(d == -1)
            target = 5
        elsif(d == -2 || d == -3)
            target = 6
        else
            target = 7
        end
        roll = roll_provider.call
        if roll >= target
            return true 
        elsif reroll
            roll = roll_provider.call
            if roll >= target
                return true
            end
        end
        false
    end
end

module ArmourBane
    def pen
        Dice.two_d6.call + s
    end
end

module Template 
    def hits(target)
        return 0 if target.flying?
        hits = count * [$template_hits, target.count].min
        Shoot40k.logger.debug("Hit!" * hits)
        hits
    end

    def ignore_cover?
        true
    end

    def reroll_hits?
        false
    end

    def reroll_wounds?
        singleton_class.included_modules.include? TwinLinked
    end
  
end

module IgnoreCover
    def ignore_cover?
        true
    end
end

module TwinLinked 
    def reroll_hits?
        true
    end
end

module Rending 
    def pen
        d1 = Dice.d6.call
        d2 = 0
        d2 = Dice.d3.call if d1 == 6
        @wnd_roll = d1
        s + d1 + d2
    end

    def ap
        if @wnd_roll == 6
Shoot40k.logger.debug "Rend!"
            2
        else
            super
        end
    end

    def wounds?(t)
        @wnd_roll = Dice.d6.call
	return true if @wnd_roll == 6
        return true if Charts.wound?(s, t, lambda {@wnd_roll}, false)
        if reroll_wounds?
            @wnd_roll = Dice.d6.call
            return true if @wnd_roll == 6
            return true if Charts.wound?(s, t, lambda {@wnd_roll}, false)
        end
        false
    end

end

module Snapshot
    def bs(target)
        1
    end
end

module Skyfire
    def bs(target)
        if(target.flying? || target.skimmer?)
            @bs
        else
            1
        end
    end
end

module Interceptor
    def bs(target)
        @bs
    end
end

class Weapon
    attr_reader :s, :count
    def initialize(count, bs, s, ap, *specials)
        @count = count
        @bs = bs
        @s = s
        @ap = ap
        extend(*specials) if specials && !specials.empty?
    end

    def shoot(target)
        #1 determine hits
        nhits = hits(target)
        #2 apply to target
        target.take_hits(nhits, self)
    end

    def reroll_hits?
        false
    end

    def hits(target)
        counter = 0
        1.upto(count) do |i|
            if Charts.shoot_hit?(bs(target), Dice.d6, reroll_hits?)
		counter += 1
                Shoot40k.logger.debug "Hit!" 
            end
        end
        counter
    end
 
    def bs(target)
        if(target.flying?)
            1
        else
            @bs
        end
    end

    def ignore_cover?
        false
    end

    def max_armour
        14
    end

    def reroll_wounds?
        false
    end

    def wounds?(t)
        Charts.wound?(s, t, Dice.d6, reroll_wounds?)
    end

    def ap
        @ap
    end

    def pen
        Dice.d6.call + s
    end

    def ap_mod
        case ap
            when 7
                -1
            when 1
                 2
            when 2
                 1
            else
                0
        end
    end
end

class Shooting
    def initialize(weapons, target)
        @w = weapons
        @t = target
    end

    def shoot
        inst = TargetStatus.new(@t)
        @w.each{|w| w.shoot(inst)}
        inst.interpret
    end
end

class Save
    def initialize(armour, invulnerable = 7, cover = 7)
        @a = armour
        @i = invulnerable
        @c = cover
    end

    def best(ap = 7, ignore_cover = false)
        [
            @a < ap ? @a : 7,
            @i,
            ignore_cover ? 7 : @c
        ].min
    end

    def save?(weapon, roll_provider = Dice.d6)
        sv = best(weapon.ap, weapon.ignore_cover?)
        roll_provider.call >= sv
    end
end

module OpenTopped
    def open_topped?
        true
    end
end

module Flyer
    def flying?
        true
    end
end

class Target
    attr_reader :name, :count, :sv
    def initialize(name, count, sv, *types)
        @name = name
        @count = count
        @sv = sv
        @events = Hash.new(0) 
        @data = []
        extend(*types) if types && !types.empty?
    end 

    def open_topped?
        false
    end
  
    def flying?
        false
    end

    def skimmer?
        false
    end 
    
    def count_event(*names)
        names.each{|n| @events[n] += 1}
    end

    def count_data(n)
        @data << n
    end

    def result
        d, e = @data, @events
        @data = []
        @events = Hash.new(0)
        return Stats.new(d), e
    end
end

class Infantry < Target
    def initialize(name, count, t, sv, ld, *types)
        super(name, count, sv, *types)
        @t = t
        @ld = ld
    end

    def initial_state
        0
    end

    def take_hits(state, nhits, weapon)
        1.upto(nhits) do |hit|
            if(weapon.wounds?(@t))
Shoot40k.logger.debug "Wound!"
                unless @sv.save?(weapon)
                    state.damage += 1
                    Shoot40k.logger.debug "No Save!" 
                end
            end
        end
    end

    def interpret(state)
        v = [@count, state.damage].min
        count_data(v)
        count_event("Wiped out") if v == @count
        count_event("Broken") if v * 4 > @count && break_test
    end

    def break_test
        Dice.two_d6.call > @ld
    end
end

class Vehicle < Target
    def initialize(name, count, armour, hull_points, weapon_count = 1, sv = Save.new(7), *types)
        super(name, count, sv, *types)
        @armour = armour 
        @hull_points = hull_points
        @weapon_count = weapon_count
    end

    def initial_state
        {:hp => 0, :results => []}
    end

    def take_hits(state, nhits, weapon)
        1.upto(nhits) do |hit|
            ap_roll = weapon.pen
            a = [weapon.max_armour, @armour].min
            if(ap_roll == a) #glancing hit
              next if @sv.save?(weapon)
              lose_hull_point(state)
            elsif(ap_roll > a) #penetrating hit
              next if @sv.save?(weapon)
                lose_hull_point(state)
                result = [(rand(6) + 1 + weapon.ap_mod + (open_topped? ? 1 : 0)), 6].min
                result = 5 if result == 4 && state.damage[:results].count{|r| r == 4} >= @weapon_count
                lose_hull_point(state) if result == 5 && state.damage[:results].count{|r| r == 5} >= 1
                state.damage[:results] << result
            end
        end
    end

    def lose_hull_point(state)
        state.damage[:hp] += 1
        state.damage[:results] << 3.5
        state.damage[:results] << 5.5 if state.damage[:hp] >= @hull_points
    end

    def interpret(state)
        count_data([@hull_points, state.damage[:hp]].min)
        v = state.damage[:results].max
        case v
           when 3.5
		count_event("Any")
           when 4, 5
                count_event("Any", "Damaged")
           when 5.5, 6
                count_event("Any", "Damaged", "Wrecked")
        end
    end
end

class TargetStatus
    attr_accessor :damage
    def initialize(target)
        @t = target
        @damage = target.initial_state
    end

    def take_hits(nhits, weapon)
        @t.take_hits(self, nhits, weapon)
    end

    def interpret
        @t.interpret(self)
    end

    def respond_to?(meth)
        super || @t.respond_to?(meth)
    end

    def method_missing(meth, *args, &block)
        if @t.respond_to?(meth)
            @t.send(meth, *args)
        else
            super
        end
    end
end

class WeaponSet < Array
    attr_reader :name
    def initialize(name, *weapons)
        super(weapons)
        @name = name
    end
end

end # Module Shoot40k
