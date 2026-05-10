pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- main hooks
function _init()
	global_time=0
	init_grid()
	init_player()
end

function _update()
	update_player()
	global_time+=1
end

function _draw()
	cls(grid_col)
	draw_grid()
	draw_player()
	print("timer:"..global_time,66,1)
end
-->8
-- grid manager

function init_grid()

	cell_size=4
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

function grid_update()
	
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
	rectfill(x_0,y_0,x_1,y_1,cell_col)	
end
-->8
-- player controller

function init_player()
	player={x=1,y=1,spr_id=0,
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
-- helpers

-- game logic

-- drawing

function draw_on_grid(x,y,spr_id,scale)
 local x_pos=x*cell_size
 local y_pos=y*cell_size
 
 spr(spr_id,x_pos,y_pos)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
