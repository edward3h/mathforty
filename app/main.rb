#!/usr/bin/env ruby

require_relative 'shoot40k_6_2'
include Shoot40k

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
#     WeaponSet.new("Test lasgun", Weapon.new(1, 3, 3, 7)),
#     WeaponSet.new("Test flamer", Weapon.new(1, 3, 4, 5, Template)),
#     WeaponSet.new("Test assault cannon", Weapon.new(4, 3, 6, 4, Rending)),
#     WeaponSet.new("Test lascannon", Weapon.new(1, 3, 9, 2)),
     WeaponSet.new("Firestorm Redoubt", Weapon.new(4, 2, 9, 2, TwinLinked, Skyfire, Interceptor)),
     WeaponSet.new("Quad gun (BS4)", Weapon.new(4, 4, 7, 4, TwinLinked, Skyfire, Interceptor)),
     WeaponSet.new("Stalker", Weapon.new(4, 4, 7, 4, TwinLinked, Skyfire)),
     WeaponSet.new("Hunter", Weapon.new(1, 4, 7, 2, ArmourBane, Skyfire)),
     WeaponSet.new("Devs 5 Flakk 2", Weapon.new(2, 4, 7, 4, Skyfire), Weapon.new(3, 4, 4, 5)),
     WeaponSet.new("Devs 5 Krak 2", Weapon.new(2, 4, 8, 3), Weapon.new(3, 4, 4, 5)),
     WeaponSet.new("Devs 5 Lascannon 2", Weapon.new(2, 4, 9, 2), Weapon.new(3, 4, 4, 5)),
]
targets = [
#    Infantry.new("10 Space Marines", 10, 4, Save.new(3, 7, 4), 9),
#    Infantry.new("10 Imperial Guard", 10, 3, Save.new(5, 7, 7), 8),
#    Infantry.new("Test Target T3 no armour", 1, 3, Save.new(7, 7, 7), 7),
#    Infantry.new("5 Terminators", 5, 4, Save.new(2, 5, 7), 9),
#    Infantry.new("Daemon Prince", 4, 5, Save.new(3, 5, 4), 13),
     Infantry.new("Bloodthirster", 6, 6, Save.new(3, 5), 13, Flyer),
#    Vehicle.new("Trukk Front", 1, 10),
    Vehicle.new("Rhino Front", 1, 11, 3),
#    Vehicle.new("Sisters Rhino Front", 1, 11, 3, 1, Save.new(7, 6)),
#    Vehicle.new("Penitent Engine", 1, 11, 3, 2, Save.new(7, 6), OpenTopped),
#    Vehicle.new("Chimera Front", 1, 12, 3, 2),
#    Vehicle.new("Predator Front", 1, 13),
#    Vehicle.new("Land Raider", 1, 14, 4, 3),
    Vehicle.new("Stormtalon", 1, 11, 2, 2, Save.new(7), Flyer),
    Vehicle.new("Night scythe", 1, 11, 3, 2, Save.new(7), Flyer),
]

targets.each do |target|
    shooters.each do |weapons|
        shooting = Shooting.new(weapons, target)
        1.upto(times) do |i|
            shooting.shoot
        end
        stats, events = target.result
        cols = []
        cols << sprintf("%32.32s vs. %32.32s", weapons.name, target.name)
        cols << sprintf("Mean: %.2f", stats.mean)
        cols << sprintf("80th percentile: %.2f",  stats.percentile(20))
        events.keys.sort.each do |evt|
            cols << "#{evt}: #{100 * events[evt] / times}%"
        end
        puts cols.join(',')
    end
end
