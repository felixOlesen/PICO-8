pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
init_grid()
init_player()
end

function _update()
	update_grid()
	update_player()
end

function _draw()
	cls(0)
	draw_grid()
	draw_player()

end
-->8
--grid
function init_grid()
	grid={}
	grid_w=10
	grid_h=10
	c_gap_y=12
	c_gap_x=16
	origin_x=-16
	origin_y=64
	grid_space=16
	c_h=4
	make_grid()
	
end

function update_grid()
	
end

function draw_grid()
	for cell in all(grid) do
		draw_cell(cell)
	end
end

function make_grid()
	local x_temp=origin_x
	local y_temp=origin_y
	for i=1,grid_h do
		x_temp=origin_x+(i-1)*8
		y_temp=origin_y+(i-1)*4
			for j=1,grid_w do
			x_temp,y_temp=move(x_temp,y_temp,"right")
			add(grid,{x=x_temp,
													y=y_temp,
													h=c_h,
													c_x=(j-1),
													c_y=(i-1)})
		end
	end
end

function move(x,y,dir)
	if dir=="up" then
		return x-8,y-4
	elseif dir=="right" then
		return x+8,y-4
	elseif dir=="down" then
		return x+8,y+4
	elseif dir=="left" then
		return x-8,y+4
	end
end

function draw_cell(c)
	pset(c.x,c.y,12)
	--top square
	line(c.x-8,c.y,c.x,c.y+4,11)
	line(c.x+8,c.y,c.x,c.y+4,11)
	line(c.x+8,c.y,c.x,c.y-4,11)
	line(c.x-8,c.y,c.x,c.y-4,11)
	
	if c.c_x==0 and c.c_y==grid_h-1 then
		--bottom square
		line(c.x-8,c.y+c_h,c.x,c.y+4+c_h,11)
		line(c.x+8,c.y+c_h,c.x,c.y+4+c_h,11)
		--vertical lines
		line(c.x,c.y+4+c_h,c.x,c.y+4)
	elseif c.c_x==0 then
		--bottom square
		line(c.x-8,c.y+c_h,c.x,c.y+4+c_h,11)
		--vertical lines
		line(c.x-8,c.y+c_h,c.x-8,c.y,11)
		line(c.x,c.y+4+c_h,c.x,c.y+4)
	elseif c.c_y==grid_h-1 then
		--bottom square
		line(c.x+8,c.y+c_h,c.x,c.y+4+c_h,11)
		--vertical lines
		line(c.x,c.y+4+c_h,c.x,c.y+4)
		line(c.x+8,c.y+c_h,c.x+8,c.y,11)
	end
end
-->8
--player
function init_player()
	player={x=64,
									y=64,
									sprite=1}
end

function update_player()
	if btnp(2) then
		dir="up"
		player.x,player.y=move(player.x,player.y,dir)
	elseif btnp(1) then
			dir="right"
			player.x,player.y=move(player.x,player.y,dir)
	elseif btnp(3) then
			dir="down"
			player.x,player.y=move(player.x,player.y,dir)
	elseif btnp(0) then
			dir="left"
			player.x,player.y=move(player.x,player.y,dir)
	end
end

function draw_player()
	spr(player.sprite,player.x-4,player.y-4)
	pset(64,64,7)
end
__gfx__
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
