scoreboard players add @s camera_mark 1
execute if score @s camera_mark matches 2.. run scoreboard players set @s camera_mark 0
posteffect clear @s
execute if score @s camera_mark matches 0 run posteffect add @s camera:bus_a
execute if score @s camera_mark matches 1 run posteffect add @s camera:bus_b
posteffect add @s camera:photo