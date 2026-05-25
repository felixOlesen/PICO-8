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
	init_items()
	init_ui()
end

function _update()
	if(glob_state.state=="started") then
		update_player()
		update_grid()
		update_items()
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
		draw_items()
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
	deep_water=7
	
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
			if(tile_type<1) add(grid[y],dirt)
			if(tile_type>=1 and tile_type<2) add(grid[y],grass)
			if(tile_type>=2) add(grid[y],water)
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
				
				if(choice>di_prob+wa_prob) add(new_grid[y],grass)
				if(choice<=di_prob+wa_prob and choice>di_prob) add(new_grid[y],water)
				if(choice<=di_prob) add(new_grid[y],dirt)
			end
		end
		grid=new_grid	
	end
end

function count_adjacent_tiles(x,y)
	local counts={gr=0,wa=0,di=0}
	local cell_type=grass
	local middle_cell=grid[y][x]
	for i=-1,1 do
		for j=-1,1 do
			if not(i==0 and j==0) then
				if x+i>=1 and y+j>=1 and x+i<=num_cells and y+j<=num_cells then
					cell_type=grid[y+j][x+i]
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
				local mid_cell=grid[y][x]
				if(t_cnt.wa==0 and t_cnt.di==0) then add(new_grid[y],light_grass)
				elseif(t_cnt.gr==0 and t_cnt.di==0) then add(new_grid[y],deep_water)
				elseif(t_cnt.wa==0 and t_cnt.gr==0) then add(new_grid[y],rock)
				elseif(((t_cnt.wa==0 or t_cnt.wa==1) and mid_cell==water) and t_cnt.gr>=t_cnt.di) then add(new_grid[y],grass)
				elseif(((t_cnt.wa==0 or t_cnt.wa==1) and mid_cell==water) and t_cnt.gr<t_cnt.di) then add(new_grid[y],dirt)
				elseif(((t_cnt.di==0 or t_cnt.di==1) and mid_cell==dirt) and t_cnt.gr<t_cnt.wa) then add(new_grid[y],water)
				elseif(((t_cnt.di==0 or t_cnt.di==1) and mid_cell==dirt) and t_cnt.gr>=t_cnt.wa) then add(new_grid[y],grass)
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
	local cell_col=grid[cell_y][cell_x]
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

-- drawing

function draw_on_grid(x,y,spr_id,scale)
 local x_pos=x*cell_size
 local y_pos=y*cell_size
 
 spr(spr_id,x_pos,y_pos)
end
-->8
-- items

function init_items()
	items={}
end

function update_items()
	if(glob_state.state=="started") do
		if(btnp(❎)) add_item("house")
	end
end

function draw_items()
	for item in all(items) do
		spr(item.spr_id,
		item.x*cell_size,
		item.y*cell_size)
	end
end

function add_item(item_type)
	local item={x=player.x,
													y=player.y,
													spr_id=5}
	
	add(items,item)
end
__gfx__
00000000111100001000000000000000000000000000006000000060000000000000000000000000000000000000000000000000000000000000000000000000
01100110100100000100000000000400000000000000060000000600000000000000000000000000000000000000000000000000000000000000000000000000
01000010100100000000000000004440000660000000020000000200000000000000000000000000000000000000000000000000000000000000000000000000
00000000111100000000000000044220006666000088880000bbbb00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000044200000666600088888800bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000
0100001000000000000000000442000000d66d0000f4cf0000f4cf00000000000000000000000000000000000000000000000000000000000000000000000000
01100110000000000000000002200000005dd50000f4ff0000f4ff00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
