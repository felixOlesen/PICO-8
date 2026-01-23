pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	game_state=1
	fire_parts={}
	debug=true
	global_time=0
	fire_freq=1
	
	bgcircles={}
	add_bgcircs()
	
end


function _update()
	if game_state==1 then
		update_1()
	end
	global_time+=1
end


function _draw()
 cls(0)
	if game_state==1 then
		draw_1()
	end
	if debug==true then
		draw_debug()
	end
end
-->8
--update

function update_1()
if global_time%fire_freq==0 then
	make_fire()
end
	if #fire_parts>0 then
		move_parts()
	end
end

function make_fire()
	local part_x,part_y=64,64
	local part_spdy=-2
	local part_spdx=0
	local rand_val=1
	local part_size=7
	local part_color=7
	local part_start_age=global_time
	local part_age_limit=20
	part={x=part_x,y=part_y,
						r=part_size,
						col=part_color,
						spdx=part_spdx,
						spdx_pred=0,
						spdy=part_spdy,
						start_age=part_start_age,
						age=0, 
						age_limit=part_age_limit}
	
	local spd_dir=rnd(1)
	if spd_dir<0.4 then
		part.spdx_pred=-0.3
	else
		part.spdx_pred=0.2
	end
	
	add(fire_parts,part)
end

function move_parts()
	for part in all(fire_parts)do
		part.x+=part.spdx
		part.y+=part.spdy
		
		if part.x>=128 or part.y>128 then
			del(fire_parts,part)
		end
		age_part(part)
	end
end

function move_bgcircles()
	for circle in all(bgcircles)do
		circle.x+=sin(global_time/360)
		circle.y+=part.spdy
	end
end
-->8
--draw

function draw_1()
	--background
	draw_circs()
	--logs
	spr(0,56,58,2,2,true,false)
	spr(0,56,57,2,2,false,false)
	--fire particles
	draw_fire()
end

function draw_debug()
if fire_parts!=nil then
	local part_num=#fire_parts
	print("parts: "..part_num)
	
	local part_spd=sin(global_time/360)
	print("spd: "..part_spd)
	
	print("bg_circs:  "..#bgcircles)
end
	
end

function draw_fire()
	for part in all(fire_parts)do
		circfill(part.x,part.y,
											part.r,part.col)
	end
end

function draw_circs()
	for circle in all(bgcircles)do
		circfill(circle.x,circle.y,
											circle.r,circle.c)
	end
end
-->8
--helpers

function age_part(part)
	if part==nil then
		return
	end
	part.age=global_time - part.start_age
	if part.age<=part.age_limit then
		part_transform(part)
	else
		del(fire_parts,part)
	end
end

function part_transform(part)
	local age=part.age
	local spdx_scalar=6
	local spdx_sway=7
	local rnd_scalar=0
	if rnd(1)<0.5 then
		rnd_scalar=-rnd(5)
	else
		rnd_scalar=rnd(5)
	end
	local global_spdx=sin(global_time*spdx_scalar/360)/spdx_sway*rnd_scalar
	
	if age<1 then
		--white
		part.spdx=global_spdx/5
		part.col=7
		part.r=2
		part.spdy=-1
	elseif age<2 then
		--yellow
		part.col=10
		part.r=3
		part.spdx=global_spdx/4
	elseif age<3 then
		--orange
		part.col=9
		part.r=4
		part.spdx=global_spdx/3
		part.spdy=-1.2
	elseif age<5 then
		--red
		part.col=8
		part.r=5
		part.spdy=-1.3
		part.spdx=global_spdx/2
	elseif age<6 then
		--red
		part.col=8
		part.r=4
		part.spdx=global_spdx/1
	elseif age<10 then
		--dark grey
		part.col=13
		part.r=4
		part.spdy=-1.3
	elseif age<13 then
		--light grey
		part.col=6
		part.r=3
	elseif age<16 then
		--light grey
		part.col=6
		part.r=2
	else
		--light grey
		part.col=6
		part.r=1
	end
end

function add_bgcircs()
	
circ_dark_grey={x=64,y=64,r=32,c=5}
circ_light_grey={x=64,y=64,r=16,c=6}
circ_white={x=64,y=64,r=4,c=7}

add(bgcircles,circ_dark_grey)
add(bgcircles,circ_light_grey)
add(bgcircles,circ_white)

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02444240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24244422400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
24444444442400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02244424444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00024442244449400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00002244444499940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000022444499940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000222249400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
