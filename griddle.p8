pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- main hooks
function _init()
	
	init_grid()
	init_player()
end

function _update()
	update_player()
end

function _draw()
	cls(grid_col)
	draw_grid()
	draw_player()
	
end
-->8
-- grid manager

function init_grid()

	cell_size=8
	screen_size=128
	num_cells=0
	grid_col=5
	line_col=1
	grid={}

	num_cells=screen_size/cell_size
	for y=1, num_cells do
		add(grid, {})
		for x=1, num_cells do
			local tile_type=rnd(2)
			if(tile_type>=1) add(grid[y],3)
			if(tile_type<1) add(grid[y],12)
		end
	end
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
0bb00bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb00bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
