pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function _init()
	cls()
	
	-- global brick properties
	br_w = 10
	br_h = 4
	
	-- game state
	mode = "start"
end

--
-- update
--

function _update60()
	if (mode == "start") then
		start_loop()
	elseif (mode == "game") then
		game_loop()
	elseif (mode == "gameover") then
		gameover_loop()
	elseif (mode == "win") then
		win_loop()
	end
end

function start_loop()
	if (btn(5) or btn(4)) then
		start_game()
	end
end

function game_loop()
	local nextx, nexty
	
	if (#brick_array == 0) then
		win()
	end

	if (btn(0) and not(btn(1))) then
		-- left
		if (abs(pd_dx) < pd_maxd) then
			pd_dx -= 0.8
		end
	elseif (btn(1) and not(btn(0))) then
		-- right
		if (abs(pd_dx) < pd_maxd) then
			pd_dx += 0.8
		end
	else
		pd_dx /= 1.5
	end
	
	pd_x += pd_dx
	pd_x = mid(0, pd_x, 127 - pd_w)
	
	nextx = bl_x + bl_dx
	nexty = bl_y + bl_dy

	if (nextx >= 125 or nextx <= 2) then
		nextx = mid(0, nextx, 127)
		bl_dx *= -1
		sfx(0)
	end
	
	if (nexty <= 9) then
		nexty = mid(0, nexty, 127)
		bl_dy *= -1
		sfx(0)
	end
	
	if ball_hitbox(nextx, nexty, pd_x, pd_y, pd_w, pd_h) then
		if deflx_ballbox(bl_x, bl_y, bl_dx, bl_dy, pd_x, pd_y, pd_w, pd_h) then
			bl_dx *= -1
		else
			bl_dy *= -1
		end
		add_points(10)
		sfx(1)
	end
	
	for obj in all(brick_array) do
		obj.update(obj, nextx, nexty)
	end
	
	bl_x = nextx
	bl_y = nexty
	
	if (nexty >= 126) then
		lives -= 1
		sfx(3)
		if (lives < 0) then
			gameover()
		else
			serve()
		end
	end
end

function gameover_loop()
	if btn(5) then
		start_game()
	end
end

function win_loop()
	if btn(5) then
		new_level()
	end
end

--
-- draw
--

function _draw()
	if (mode == "start") then
		draw_start()
	elseif (mode == "game") then
		draw_game()
	elseif (mode == "gameover") then
		draw_gameover()
	elseif (mode == "win") then
		draw_win()
	else
		cls()
		print("error: unknown game state")
	end
end

function draw_start()
	cls()
	align("center", "circl3s' super breakout", 56, 7)
	align("center", "press 🅾️ or ❎ to start", 62, 6)
end

function draw_game()
	cls(1)
	for obj in all(brick_array) do
		obj.draw(obj)
	end
	circfill(bl_x, bl_y, bl_r, 8)
	rectfill(pd_x, pd_y, pd_x + pd_w, pd_y + pd_h, 7)
	rectfill(0, 0, 127, 6, 0)
	print("lives: ", 1, 1, 7)
	print(livestring, 25, 1, 8)
	align("center", "lvl " .. level, 1, 14)
	align("right", "score:" .. points, 1, 7)
end

function draw_gameover()
	align("center", "game over :(", 56, 8)
	align("center", "press ❎ to restart", 62, 6)
end

function draw_win()
	align("center", "★ level 1 complete ★", 56, 10)
	align("center", "press ❎ to continue", 62, 6)
end

--
-- functions
--

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

function deflx_ballbox(bx, by, bdx, bdy, tx, ty, tw, th)
	local slp = bdy / bdx
	local cx, cy
	if bdx == 0 then
		return false
	elseif bdy == 0 then
		return true
	elseif slp > 0 and bdx > 0 then
		cx = tx - bx
		cy = ty - by
		return cx > 0 and cy/cx < slp
	elseif slp < 0 and bdx > 0 then
		cx = tx - bx
		cy = ty + th - by
		return cx > 0 and cy/cx >= slp
	elseif slp > 0 and bdx < 0 then
		cx = tx + tw - bx
		cy = ty + th - by
		return cx < 0 and cy/cx <= slp
	else
		cx = tx + tw - bx
		cy = ty - by
		return cx < 0 and cy/cx >= slp
	end
end

function update_livestring()
	local x = 0
	livestring = ""
	while (x < lives) do
		livestring ..= "♥"
		x += 1
	end
end

function serve()
	-- ball variables
	bl_x = 60
	bl_y = 64
	bl_r = 2
	bl_dx = 1
	bl_dy = 1
	
	update_livestring()
end

function gameover()
	music(61)
	mode = "gameover"
end

function win()
	music(62)
	mode = "win"
end

function start_game()
	-- paddle variables
	pd_x = 52
	pd_y = 120
	pd_w = 24
	pd_h = 3
	pd_dx = 0
	pd_maxd = 2
	
	-- brick variables
	brick_array = {}
	brick_rows = 4
	brick_cols = 9
	
	-- game state
	level = 0
	lives = 3
	points = 0
	
	new_level()
end

function new_level()
	level += 1
	mode = "game"

	for row = 1, brick_rows do
		for col = 1, brick_cols do
			add(brick_array, new_brick(1 + (col * br_w) + ((col - 1) * 2), 14 + (row * br_h) + (row * 3), flr(rnd(level) + 1)))
		end
	end
	
	serve()
	
	start_music()
end

function align(mode, t, y, c)
	local l = #t * 2
	local x = 1
	while (x <= #t) do
		if (ord(t, x) >= 128) then
			l += 2
		end
		x += 1
	end
	
	if (mode == "center") then
		print(t, 63 - l, y, c)
	elseif (mode == "right") then
		print(t, 128 - (l * 2), y, c)
	end
end

function start_music()
	music((level - 1) * 8)
end

function add_points(p)
	points += (p * level)
end

-- bricks

function new_brick(x, y, dur)
	local brick = {}
	brick.x = x
	brick.y = y
	brick.dur = dur
	
	brick.draw = function(this)
		rectfill(this.x, this.y, this.x + br_w, this.y + br_h, this.dur + 8)
	end
	
	brick.update = function(this, nextx, nexty)
		if ball_hitbox(nextx, nexty, this.x, this.y, br_w, br_h) then
			if deflx_ballbox(bl_x, bl_y, bl_dx, bl_dy, this.x, this.y, br_w, br_h) then
				bl_dx *= -1
			else
				bl_dy *= -1
			end
			add_points(100)
			sfx(4)
			this.dur -= 1
			if (this.dur <= 0) then
				del(brick_array, this)
			end
		end
	end

	return brick
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
000100002d0502d0502d0302d0202d010323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000115501155010550105500f5500f5500e5500e5500e5520e5520e5520e5520e55500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000027450224301d430164200f42009410000000000027440224301d420164200f41009410000000000027430224201d420164100f41009410000000000027420224201d410164100f410094100000000000
010100003205032050320303202032010323000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000346403363032620316302f6102c6202961027610226101c610116100b6100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000c35005350023500233000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600003a65038640376303663035620346100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c000018e50000003f6150000018e50000003f6150000018e50000003f6150000018e50000003f6150000018e50000003f6150000018e50000003f6150000018e50000003f6150000018e50000003f61500000
010c00000000000000000000000018f3018f3018f3018f300000000000000000000018f3018f3018f3018f300000000000000000000018f3018f3018f3018f300000000000000000000018f3018f3018f3018f30
000e000002050020550e0550e05502050020550e0550e05502050020550e0550e05502050020550e0550e055050500505511055110550505005055110551105500050000550c0550c05500050000550c0550c055
010e00002615500000261550000029155000002915500000281550000028155241550000024155281550000026155000002615500000291550000029155000002815500000281552415500000241552d15500000
__music__
03 48490a0b
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 02424344

