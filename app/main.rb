#!/usr/bin/env ruby

require_relative 'shoot40k_6_2'

times = ARGV[0] ? ARGV[0].to_i : 10

shooters = [
#    WeaponSet.new(
#        "10 CSM, plasma, autocannon - Range 12 - 24",
#        Weapon.new(7, 4, 4, 5),
#        Weapon.new(1, 4, 7, 2),
#        Weapon.new(2, 4, 7, 4)
#    ),
#    WeaponSet.new(
#        "10 CSM, 2 meltas - Range < 6",
#        Weapon.new(16, 4, 4, 5),
#        Weapon.new(2, 4, 8, 1, Melta.new)
#    ),
#    WeaponSet.new(
#        "9 Havocs, 1 Autocannon, 3 Krak Missile",
#        Weapon.new(5, 4, 4, 5),
#        Weapon.new(2, 4, 7, 4),
#        Weapon.new(3, 4, 8, 3)       
#    ),
#    WeaponSet.new(
#        "Stationary Land Raider",
#        Weapon.new(2, 4, 9, 2, TwinLinked.new),
#        Weapon.new(3, 4, 5, 4, TwinLinked.new)
#    ),
#    WeaponSet.new(
#        "Bikers, close, use meltas",
#        Weapon.new(6, 4, 4, 5, TwinLinked.new),
#        Weapon.new(2, 4, 8, 1, Melta.new)
#    ),
#    WeaponSet.new(
#        "Bikers, close, use bolters",
#        Weapon.new(10, 4, 4, 5, TwinLinked.new)
#    )      
#     WeaponSet.new("Hive Guard old rules", Weapon.new(6, 4, 8, 4)),
#     WeaponSet.new("Hive Guard new rules", Weapon.new(6, 3, 8, 4, IgnoreCover)),
#     WeaponSet.new("Terminator squad (assault cannon)", Weapon.new(8, 4, 4, 5), Weapon.new(4, 4, 6, 4, Rending)),
     WeaponSet.new("Test lasgun", Weapon.new(1, 3, 3, 7)),
     WeaponSet.new("Test flamer", Weapon.new(1, 3, 4, 5, Template)),
     WeaponSet.new("Test assault cannon", Weapon.new(4, 3, 6, 4, Rending)),
     WeaponSet.new("Test lascannon", Weapon.new(1, 3, 9, 2)),
]
targets = [
#    Infantry.new("10 Space Marines", 10, 4, Save.new(3, 7, 4), 9),
#    Infantry.new("10 Imperial Guard", 10, 3, Save.new(5, 7, 7), 8),
#    Infantry.new("Test Target T3 no armour", 1, 3, Save.new(7, 7, 7), 7),
#    Infantry.new("5 Terminators", 5, 4, Save.new(2, 5, 7), 9),
#    Infantry.new("Daemon Prince", 4, 5, Save.new(3, 5, 4), 13),
#    Vehicle.new("Trukk Front", 1, 10),
    Vehicle.new("Rhino Front", 1, 11, 3),
    Vehicle.new("Sisters Rhino Front", 1, 11, 3, 1, Save.new(7, 6)),
    Vehicle.new("Penitent Engine", 1, 11, 3, 2, Save.new(7, 6), OpenTopped),
#    Vehicle.new("Chimera Front", 1, 12, 3, 2),
#    Vehicle.new("Predator Front", 1, 13),
#    Vehicle.new("Land Raider", 1, 14, 4, 3),
]

targets.each do |target|
    shooters.each do |weapons|
        shooting = Shooting.new(weapons, target)
        1.upto(times) do |i|
            shooting.shoot
puts if $debug
        end
        target.print_interpretation(times, weapons)
        puts
    end
end
