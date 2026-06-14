pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- main hooks
function _init()
	glob_state={glob_time=0,
													state="main_menu",
													debug=true
												}
	init_grid()
	init_player()
	init_objects()
	init_ui()
end

function _update()
	if(glob_state.state=="started") then
		update_player()
		update_grid()
		update_objects()
	end
	update_ui()
	glob_state.glob_time+=1
end

function _draw()
	
	if(glob_state.state=="main_menu") then
		cls(1)
		draw_grid()
		draw_ui()
	elseif(glob_state.state=="settings") then
		draw_grid()
		draw_ui()
	elseif(glob_state.state=="started") then
		cls(0)
		draw_grid()
		draw_player()
		draw_objects()
		draw_ui()
	end
	
	if(glob_state.debug) then
		print("timer:"..glob_state.glob_time,66,1)	
		print("ui_option:"..ui_option,2,4,7)
	end
end
-->8
-- grid manager

function init_grid()

	cell_size=8
	screen_size=128
	grid_col=5
	line_col=1
	water=12
	grass=3
	dirt=4
	sand=15
	light_grass=13
	rock=13
	ice=7
	
	grid={}
	num_cells=screen_size/cell_size
	
	-- procedural generation
	local num_passes=20
	dirt_weight=0.95
	water_weight=0.95
	grass_weight=1
	
	initial_pass()
	procedural_gen(num_passes)
	highlight_pass()
end

function initial_pass()
	for y=1, num_cells do
		add(grid, {})
		for x=1, num_cells do
			local tile_type=rnd(3)
			if(tile_type<1) add(grid[y],{tile=dirt,object=nil})
			if(tile_type>=1 and tile_type<2) add(grid[y],{tile=grass,objec=nil})
			if(tile_type>=2) add(grid[y],{tile=water,object=nil})
		end
	end
end

function procedural_gen(num_passes)
	for i=1,num_passes do
		local new_grid={}
		for y=1, num_cells do
			add(new_grid,{})
			for x=1, num_cells do
				local tile_counts=count_adjacent_tiles(x,y)
				local gr_prob=(tile_counts.gr/8)*grass_weight
				local wa_prob=(tile_counts.wa/8)*water_weight
				local di_prob=(tile_counts.di/8)*dirt_weight
				local prob_sum=gr_prob+wa_prob+di_prob
				local choice=rnd(prob_sum)
				
				if(choice>di_prob+wa_prob) add(new_grid[y],{tile=grass,object=nil})
				if(choice<=di_prob+wa_prob and choice>di_prob) add(new_grid[y],{tile=water,object=nil})
				if(choice<=di_prob) add(new_grid[y],{tile=dirt,object=nil})
			end
		end
		grid=new_grid	
	end
end

function count_adjacent_tiles(x,y)
	local counts={gr=0,wa=0,di=0}
	local cell_type=grass
	local middle_cell=grid[y][x].tile
	for i=-1,1 do
		for j=-1,1 do
			if not(i==0 and j==0) then
				if x+i>=1 and y+j>=1 and x+i<=num_cells and y+j<=num_cells then
					cell_type=grid[y+j][x+i].tile
					if(cell_type==grass) counts.gr+=1
					if(cell_type==water) counts.wa+=1
					if(cell_type==dirt) counts.di+=1
				end
			end
		end
	end
	
	return counts
end

function highlight_pass()
		local new_grid={}
		for y=1, num_cells do
			add(new_grid,{})
			for x=1, num_cells do
				local t_cnt=count_adjacent_tiles(x,y)
				local mid_cell=grid[y][x].tile
				if(t_cnt.wa==0 and t_cnt.di==0) then add(new_grid[y],{tile=light_grass,object=nil})
				elseif(t_cnt.gr==0 and t_cnt.di==0) then add(new_grid[y],{tile=ice,object=nil})
				elseif(t_cnt.wa==0 and t_cnt.gr==0) then add(new_grid[y],{tile=rock,object=nil})
				elseif(((t_cnt.wa==0 or t_cnt.wa==1) and mid_cell==water) and t_cnt.gr>=t_cnt.di) then add(new_grid[y],{tile=grass,object=nil})
				elseif(((t_cnt.wa==0 or t_cnt.wa==1) and mid_cell==water) and t_cnt.gr<t_cnt.di) then add(new_grid[y],{tile=dirt,object=nil})
				elseif(((t_cnt.di==0 or t_cnt.di==1) and mid_cell==dirt) and t_cnt.gr<t_cnt.wa) then add(new_grid[y],{tile=water,object=nil})
				elseif(((t_cnt.di==0 or t_cnt.di==1) and mid_cell==dirt) and t_cnt.gr>=t_cnt.wa) then add(new_grid[y],{tile=grass,object=nil})
				else add(new_grid[y],grid[y][x])
				end
			end
		end
		grid=new_grid	
end

function update_grid()
end

function draw_grid()
	for y=1, num_cells do
		
		for x=1, num_cells do
			draw_grid_square(x,y)
		end
	end
end

function draw_grid_square(cell_x,cell_y)
	local x_1=cell_x*cell_size
	local y_1=cell_y*cell_size
	local x_0=x_1-cell_size
	local y_0=y_1-cell_size
	local cell_col=grid[cell_y][cell_x].tile
	if cell_x >= num_cells then
		x_1-=1
	end
	if cell_y >= num_cells then
		y_1-=1
	end
	if cell_size<=1 then
		pset(x_0,y_0,cell_col)
	else
		rectfill(x_0,y_0,x_1,y_1,cell_col)
	end
	
end
-->8
-- player controller

function init_player()
	local sprite_choice=0
	if(cell_size==8) sprite_choice=0
	if(cell_size==4) sprite_choice=1
	if(cell_size==2) sprite_choice=2
	player={x=1,y=1,
									spr_id=sprite_choice,
									spr_scale=1}
end

function update_player()
	if(not moving) move_check()
end

function draw_player()
	draw_on_grid(player.x,player.y,player.spr_id,player_spr_scale)
	print("x:"..player.x,8,1,0)
	print("y:"..player.y,24,1,0)
end

-- player utile
function move_check()
	if(btnp(0) and player.x-1>=0) player.x-=1
	if(btnp(1) and player.x+1<num_cells) player.x+=1
	if(btnp(2) and player.y-1>=0) player.y-=1
	if(btnp(3) and player.y+1<num_cells) player.y+=1
end
-->8
-- ui

function init_ui()
	ui_option=1
	settings_state="none"
	object_state="house"
end

function update_ui()
	if(glob_state.state=="main_menu") then
		if(btnp(2) and ui_option>1) ui_option-=1
		if(btnp(3) and ui_option<3) ui_option+=1	
		if(btnp(❎)) then
			if(ui_option==1) glob_state.state="started"
			if(ui_option==2) then 
				glob_state.state="settings"
				ui_option=1
			end	
			if(ui_option==3) glob_state.state="exit"
		end
	elseif(glob_state.state=="settings") then
		if(btnp(2) and ui_option>1) then 
			ui_option-=1
			settings_state="none"
		end
		if(btnp(3) and ui_option<4) then 
			ui_option+=1
			settings_state="none"
		end	
		if(btnp(❎)) then
			if(ui_option==1) settings_state="grass"
			if(ui_option==2) settings_state="dirt"
			if(ui_option==3) settings_state="water"
			if(ui_option==4) then 
				settings_state="none"
				glob_state.state="main_menu"
				ui_option=1
			end
		end
		if settings_state=="grass" then
			if btnp(0) then grass_weight-=0.05 end
			if btnp(1) then grass_weight+=0.05 end
		elseif settings_state=="dirt" then
			if btnp(0) then dirt_weight-=0.05 end
			if btnp(1) then dirt_weight+=0.05 end
		elseif settings_state=="water" then
			if btnp(0) then water_weight-=0.05 end
			if btnp(1) then water_weight+=0.05 end
		end
		
		if btnp(4) then settings_state="none" end
	end
	
	if btnp(4) and glob_state.state=="main_menu" then
		grid={}
		initial_pass()
		procedural_gen(20)
		highlight_pass()
	end
	
	if glob_state.state=="started" then
		if(btnp(4)) then
			ui_option+=1
			if(ui_option>5) ui_option=1
		end
	end
	
end

function draw_ui()
	if(glob_state.state=="main_menu") then
		-- background shapes
		local offset=17
		rectfill(5,30+offset,50,70+offset,1)
		rect(5,30+offset,50,70+offset,0)
		
		
		-- ui text
		print("griddle",8,33+offset,9)	
		print("start",11,43+offset,6)
		print("settings",11,52+offset,6)
		print("exit",11,61+offset,6)
		if(ui_option==1) then
			rect(9,41+offset,31,49+offset,7)
			print("start",11,43+offset,11)
		elseif(ui_option==2) then
			rect(9,50+offset,43,58+offset,7)
			print("settings",11,52+offset,7)
		elseif(ui_option==3) then
			rect(9,59+offset,27,67+offset,7)
			print("exit",11,61+offset,8)
		end
		
		print("press z:refresh map",30,120,15)
	elseif(glob_state.state=="settings") then
		-- background shapes
		local offset=17
		rectfill(5,30+offset,60,70+offset,1)
		rect(5,30+offset,60,70+offset,0)
		
		
		-- ui text
		print("grass:"..(grass_weight),11,34+offset,6)	
		print("dirt:"..(dirt_weight),11,43+offset,6)
		print("water:"..(water_weight),11,52+offset,6)
		print("back",11,61+offset,6)
		local f_color=7
		if(ui_option==1) then
			if (settings_state=="grass") then 
				f_color=9
			else
				f_color=7
			end
			print("grass:"..(grass_weight),11,34+offset,f_color)
		elseif(ui_option==2) then
			if (settings_state=="dirt") then 
				f_color=9
			else
				f_color=7
			end
			print("dirt:"..(dirt_weight),11,43+offset,f_color)
		elseif(ui_option==3) then
			if (settings_state=="water") then 
				f_color=9
			else
				f_color=7
			end
			print("water:"..(water_weight),11,52+offset,f_color)
		elseif(ui_option==4) then
			print("back",11,61+offset,f_color)
		end
	
	elseif glob_state.state=="started" then
		-- base shapes
		rectfill(2,115,11,124,0)
		rect(2,115,11,124,9)
		
		-- sprites
		local spr_num=6
		if ui_option==1 then
			spr_num=6
			object_state="house"
		elseif ui_option==2 then
			spr_num=7
			object_state="mine"
		elseif ui_option==3 then
			spr_num=8
			object_state="well"
		elseif ui_option==4 then
			spr_num=9
			object_state="lumber_hut"
		elseif ui_option==5 then
			spr_num=12
			object_state="road"
		end
		spr(spr_num,3,116)
	end
end
-->8
-- ideas/todo
--[[
ideas:
- save mechanic for selecting 
		a generated map and making 
		it persist.
		- reduces the compute needed 
				for generation on start.
				
- zoom in/out mechanic where 
		you have 1 or 2 pixel cell 
		size and can zoom in to 
		increase cell size and make 
		map features bigger.
		- when zoomed out, enemy pres-
				ence is red, yours is blue

- fog of war mechanic where the 
		map is still generated but not 
		visible unless explored.
		- like an rts, make enemy move-
				ment not visible.
 
- traversing outside the map
		requires either generating
		connecting area, or if zoomed,
		the next pixel over.

todo:

- optimise the generation algo-
		rithm.
		- improve looping through the
				grid.

completed:


]]
-->8
-- helpers

-- game logic
function update_road_rules()
	-- loop through all roads
	-- check adjacent tiles for roads
	if count(roads)>0 then
		for road in all(roads) do
			local north=false
			local east=false
			local south=false
			local west=false
			--north
			if road.y-1>=0 then
				--one indexed: +1 -1
				if grid[road.y][road.x+1].object != nil and grid[road.y][road.x+1].object.obj_type=="road" then
					north=true
				end
			end
			--east
			if road.x+1<#grid[1] then
				--one indexed: +1 +1
				if grid[road.y+1][road.x+2].object != nil and grid[road.y+1][road.x+2].object.obj_type=="road" then
					east=true
				end
			end
			--south
			if road.y+1<#grid then
				--one indexed: +1 +1
				if grid[road.y+2][road.x+1].object != nil and grid[road.y+2][road.x+1].object.obj_type=="road" then
					south=true
				end
			end
			--west		
			if road.x-1>=0 then
				--one indexed: +1 -1
				if grid[road.y+1][road.x].object != nil and grid[road.y+1][road.x].object.obj_type=="road" then
					west=true
				end
			end
			
			if north and east and west and south then
				road.spr_id=12
			elseif north and east and west then
				road.spr_id=46
			elseif south and east and west then
				road.spr_id=15
			elseif south and north and west then
				road.spr_id=31
			elseif south and north and east then
				road.spr_id=47
			elseif south and north then
				road.spr_id=13
			elseif east and west then
				road.spr_id=11
			elseif north and west then
				road.spr_id=29
			elseif north and east then
				road.spr_id=28
			elseif south and west then
				road.spr_id=27
			elseif south and east then
				road.spr_id=14
			elseif north then
				road.spr_id=30
			elseif east then
				road.spr_id=45
			elseif south then
				road.spr_id=43
			elseif west then
				road.spr_id=44
			end
			
		end
	end
	
end

-- drawing

function draw_on_grid(x,y,spr_id,scale)
 local x_pos=x*cell_size
 local y_pos=y*cell_size
 
 spr(spr_id,x_pos,y_pos)
end

function get_gen_yield(object)
	local stone_sum=object.gen.stone
	local water_sum=object.gen.water
	local food_sum=object.gen.food
	local wood_sum=object.gen.wood
	
	if object.tile==ice then
		stone_sum*=object.gen_w.ice
		water_sum=object.gen_w.ice
		food_sum=object.gen_w.ice
		wood_sum=object.gen_w.ice
	elseif object.tile==grass then
		stone_sum*=object.gen_w.grass
		water_sum=object.gen_w.grass
		food_sum=object.gen_w.grass
		wood_sum=object.gen_w.grass
	elseif object.tile==dirt then
		stone_sum*=object.gen_w.dirt
		water_sum=object.gen_w.dirt
		food_sum=object.gen_w.dirt
		wood_sum=object.gen_w.dirt
	elseif object.tile==rock then
		stone_sum*=object.gen_w.rock
		water_sum=object.gen_w.rock
		food_sum=object.gen_w.rock
		wood_sum=object.gen_w.rock
	end
	
	return {stone_sum,
									water_sum,
									food_sum,
									wood_sum}
end

function make_yield_nums(object)
	local yields=get_gen_yield(object)
	
	for y in all(yields) do
		if y > 0 then
			add(yield_nums, {x=object.x,y=object.y,yield_num=y,life=3})
		end
	end
	
end

-->8
-- objects

function init_objects()
	objects={}
	roads={}
	yield_nums={}
end

function update_objects()
	if(glob_state.state=="started") do
		if(btnp(❎)) add_object(object_state)
	
		if glob_state.glob_time%30==0 then
			for obj in all(objects) do
				obj.yld_time -= 1
				if obj.yld_time <= 0 then
						make_yield_nums(obj)
						obj.yld_time = obj.yld_time_max
				end
			end
		end
		if #yield_nums > 0 then
			move_yield_nums()
		end
	end
end

function draw_objects()
	for object in all(objects) do
		spr(object.spr_id,
		object.x*cell_size,
		object.y*cell_size)
	end
	for yild in all(yield_nums) do
		print(yild.yield_num, yild.x*cell_size, yild.y*cell_size,7)
	end
end

function add_object(object_type)
	if(grid[player.y+1][player.x+1].object != nil) then
		return
	end
	if(grid[player.y+1][player.x+1].tile==water) then
		return
	end

	local spr_num=16

	local dirt_w=1
	local grass_w=1
	local rock_w=1
	local ice_w=1

	local g_stone=0
 local g_wood=0
 local g_water=0
 local g_food=0
 
 local yield_time_max=1
 
	if(object_type=="house") then
		spr_num=6
		dirt_w=1
		grass_w=1
		rock_w=0.5
		ice_w=0.75
		g_stone=0
	 g_wood=0
	 g_water=0
	 g_food=2
	 yield_time_max=1
	elseif(object_type=="mine") then 
		spr_num=7
		dirt_w=0.5
		grass_w=0.25
		rock_w=1
		ice_w=0
		g_stone=2
	 g_wood=0
	 g_water=0
	 g_food=0
	 yield_time_max=2
	elseif(object_type=="well") then 
		spr_num=8
		dirt_w=1
		grass_w=0.5
		rock_w=0
		ice_w=1
		g_stone=0
	 g_wood=0
	 g_water=2
	 g_food=0
	 yield_time_max=3
	elseif(object_type=="lumber_hut") then 
		spr_num=9
		dirt_w=0.25
		grass_w=1
		rock_w=0
		ice_w=0
		g_stone=0
	 g_wood=2
	 g_water=0
	 g_food=0
	 yield_time_max=4
	elseif(object_type=="road") then 
		spr_num=12
		dirt_w=0
		grass_w=0
		rock_w=0
		ice_w=0
		g_stone=0
	 g_wood=0
	 g_water=0
	 g_food=0
	 yield_time_max=100
	end

	local object={x=player.x,
													y=player.y,
													spr_id=spr_num,
													obj_type=object_type,
													tile=grid[player.y+1][player.x+1].tile,
													gen_w={grass=grass_w,
																		dirt=dirt_w,
																		rock=rock_w,
																		ice=ice_w},
													gen={stone=g_stone,
																		wood=g_wood,
																		water=g_water,
																		food=g_food},
													yld_time_max=yield_time_max,
													yld_time=yield_time_max
													}
	
	add(objects,object)
	grid[player.y+1][player.x+1].object=object
	if(object_type=="road") then
	 add(roads,object)
	 update_road_rules()
	end
end

function move_yield_nums()
	local y_spd=0.2
	for num in all(yield_nums) do
		num.y-=y_spd
		num.life-=0.3
		if num.life<=0 then
			del(yield_nums,num)
		end
	end
end
__gfx__
00000000111100001000000000000100000110000000000000000161000000000011110000000000000000000000000000144100001441000000000000000000
01100110100100000100000000001410001661000000c00000001610000110000188881000100000000000000000000000144100001441000000000000000000
0100001010010000000000000001444101666610000cc00000111210001551001888888101b10100000000001111111111144111001441000001111111111111
000000001111000000000000001442210166661000c7cc000188881001555510014cc4101bbb1810000000004444444444444444001441000014444444444444
0000000000000000000000000144211001d66d1000cccc001888888101588510016cc610bbbb8f81000000004444444444444444001441000014444444444444
01000010000000000000000014421000015dd510001cc10001f4cf101541145101d66d101343f4c8000000001111111111144111001441000014411111144111
01100110000000000000000012210000001551000001100001f4ff1015411451001dd1000141f4f1000000000000000000144100001441000014410000144100
00000000000000000000000001100000000110000000000000111100011111100001100000101110000000000000000000144100001441000014410000144100
00000000770000770000000000000000000000000000000000000161000000000011110000000000000000000000000000144100001441000014410000144100
080000807000000700000000001100000000000000000000000016100001100001bbbb1000100000000000000000000000144100001441000014410000144100
00800800000000000000000001841000000000000000000000111210001551001bbbbbb101310100000000001111100000144111111441000014410011144100
00088000000000000000000016884100000000000000000001bbbb1001555510014cc41013331b10000000004444410000144444444441000014410044444100
0008800000000000000000000161141000000000000000001bbbbbb1015bb510016cc61033333fb1000000004444410000144444444441000001100044444100
00800800000000000000000000100141000000000000000001f4cf101541145101d66d101242f4cb000000001114410000011111111110000000000011144100
08000080700000070000000000000010000000000000000001f4ff1015411451001dd1000141f4f1000000000014410000000000000000000000000000144100
00000000770000770000000000000000000000000000000000111100011111100001100000101110000000000014410000000000000000000000000000144100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014410000144100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014410000144100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011110000000011111114411100144111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001100044441000000144444444444400144444
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014410044441000000144444444444400144444
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014410011110000000011111111111100144111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014410000000000000000000000000000144100
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014410000000000000000000000000000144100
