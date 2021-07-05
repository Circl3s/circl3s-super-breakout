pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	cls()
	
	-- ball variables
	bl_x = 1
	bl_y = 40
	bl_r = 2
	bl_dx = 2
	bl_dy = 2

	-- paddle variables
	pd_x = 52
	pd_y = 120
	pd_w = 24
	pd_h = 3
	pd_dx = 0
	pd_maxd = 4
end

function _update()
	local nextx, nexty

	if (btn(0) and not(btn(1))) then
		-- left
		if (abs(pd_dx) < pd_maxd) then
			pd_dx -= 2
		end
	elseif (btn(1) and not(btn(0))) then
		-- right
		if (abs(pd_dx) < pd_maxd) then
			pd_dx += 2
		end
	else
		pd_dx /= 1.69
	end
	
	pd_x += pd_dx
	
	nextx = bl_x + bl_dx
	nexty = bl_y + bl_dy

	if (nextx >= 127 or nextx <= 0) then
		nextx = mid(0, nextx, 127)
		bl_dx *= -1
		sfx(0)
	end
	
	if (nexty >= 127 or nexty <= 0) then
		nexty = mid(0, nexty, 127)
		bl_dy *= -1
		sfx(0)
	end
	
	if ball_hitbox(nextx, nexty, pd_x, pd_y, pd_w, pd_h) then
		ball_bounce(pd_x, pd_y, pd_w, pd_h)
		sfx(1)
	end
	
	bl_x = nextx
	bl_y = nexty
end

function _draw()
	cls(1)
	circfill(bl_x, bl_y, bl_r, 8)
	rectfill(pd_x, pd_y, pd_x + pd_w, pd_y + pd_h, 7)
end

function ball_hitbox(nx, ny, box_x, box_y, box_w, box_h)
	-- top edge of ball
	if (ny - bl_r > box_y + box_h) then
		return false
	end

	-- bottom edge of ball
	if (ny + bl_r < box_y) then
		return false
	end

	-- left edge of ball
	if (nx - bl_r > box_x + box_w) then
		return false
	end
	
	-- right edge of ball
	if (nx + bl_r < box_x) then
		return false
	end
	
	return true
end

function ball_bounce(box_x, box_y, box_w, box_h)
	local d1, d2, d3, d4
	d1 = dist(bl_x, bl_y, box_x, box_y)
	d2 = dist(bl_x, bl_y, box_x + box_w, box_y)
	d3 = dist(bl_x, bl_y, box_x + box_w, box_y + box_h)
	d4 = dist(bl_x, bl_y, box_x, box_y + box_h)
	
	if ((d1 < d2 and d3 < d4) or (d2 < d1 and d4 < d3)) then
		bl_dx *= -1
	else
		bl_dy *= -1
	end
end

function dist(x1, y1, x2, y2)
	return sqrt((x1 - x2)^2 + (y1 - y2)^2)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002605026050260302602026010323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001235011340103301032010310103100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
