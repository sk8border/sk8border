pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- bust up the border wall!

debug = false

-- constants
tpb=16 // ticks per beat
lst=16*tpb // loopstart tick
let=lst+176*tpb // loopend tick
theme_intro_delay = 4 * tpb
early = 8 // early display ticks
lyric_t_offset =
 early - theme_intro_delay
v1_recur = {0, 32*tpb}
lyrics = {
 {"♪we're gonna take♪",
  -- span of time to display
  {32*tpb, 36*tpb},
  -- list of time offsets for
  -- recurring display
  v1_recur},
 {"♪down that wall♪",
  {36*tpb, 39*tpb},
  v1_recur},
 {"♪down that wall♪",
  {40*tpb, 43*tpb},
  v1_recur},
 {"♪down that wall♪",
  {44*tpb, 46.5*tpb},
  v1_recur},
 {"♪break it!♪",
  {46.5*tpb, 49*tpb},
  v1_recur},
 {"♪we will tear♪",
  {49*tpb, 52*tpb},
  v1_recur},
 {"♪down that wall♪",
  {52*tpb, 56*tpb},
  v1_recur},
 {"♪that wall is comin down♪",
  {56*tpb, 60*tpb},
  v1_recur},
 {"*interlude harmonique*",
  {96*tpb, 112*tpb},
  {0}},
}

keys = {
 left=0,
 right=1,
 up=2,
 down=3,
 a=4,
 b=5
}

states = {
 idle=0,
 crouch=1,
 launch=2,
 jump=3,
 grind=4,
 down=5,
 land=6
}

snd = {
 explode=19,
 skate=22,
 jump=23,
 grind=24
}

rubble = {
	{i=64,w=2,h=1},
	{i=66,w=1,h=1},
	{i=67,w=1,h=1},
	{i=68,w=1,h=1}
}

posters = {
	{i=12,w=4,h=4},
	{i=8,w=4,h=2}
}

explosion_frames = {
140,142,236,238
}

scoring = {
 -- base number of ticks for
 -- the score to increase by 1
 -- while grinding
 -- set to this value when
 -- grinding starts
 interval_base=15,
 -- if grinding on the opposite
 -- time as last time, 
 -- that interval start as
 -- this number of ticks
 interval_alt=5,
 -- whenever score is increased
 -- by grinding, decrease the
 -- interval by this many ticks
 interval_drop_rate=5,
 -- but not below this
 interval_min=3,
 -- stop raking points when
 -- grinding for over this many
 -- ticks uninterrupted
 max_grind_ticks=60,
 -- points when grinding starts
 grind_start_pts=1,
 -- points when walls are destroyed
 destruction_pts=100,
 -- wheter to destroy walls
 -- when falling, besides
 -- when jumping
 -- (if gauge is filled)
 destroy_on_fall=false
}

  -- acceleration due to gravity
game_duration = 60
g = 0.2
jump_speed = 5
playerheight = 24
ground_y = 8*14.5
launch_time = 12
launch_frame_time = 6
max_grind_y = 40
land_time = 10
idle_bob_time = 8
title_wall_y = 8 * 8
start_delay = 40
scroll_speed = 1.5
-- end constants


-- global variables
game_started = false
game_over = false
-- in seconds
t = nil
player = nil
frm = 0
launch_t = nil
land_t = nil
p_state = states.idle
lastwall = nil
start_countdown = nil
-- end global variables

function make_player(x,y)
  local p = {}
  p.x = x
  p.y = y
  p.dy = 0
  p.ddy = g  -- acceleration due to gravity
  return p
end

function add_to_score(points)
 score += points*gauge.multiplier
 set_gauge_value(
  gauge,
  gauge.value+points
 )
end

function check_for_destruction()
 if gauge.maxed then
  break_all_walls()
  score += scoring.destruction_pts
  reset_gauge(gauge)
  return true
 end
 return false
end

function play_snd(index)
 sfx(-1, 3)
 sfx(index, 3)
end


function update_player(p)
  if not game_started then
   return
  end

		local sc = scoring
  local ps = p_state

  function check_for_jump()
   if not (
    btn(keys.a) or btn(keys.b)
   ) then
    p_state = states.launch
    launch_t = t
    p.dy = -jump_speed
    if not check_for_destruction()
    then
     play_snd(snd.jump)
    end
   end
  end

  -- used for grinding
  local current_wall = nil

  if ps == states.idle then
   if (
    btn(keys.a) or btn(keys.b)
   ) then
    p_state = states.crouch
   end
  elseif ps == states.crouch then
   check_for_jump()
  elseif ps == states.launch then
   if (
    t - launch_t >= launch_time
   ) then
    p_state = states.jump
   end
  elseif ps == states.jump then
   if (
    p.dy > 0 and
    ground_y-p.y < max_grind_y
   ) then
    p_state = states.down
   else
     if (btn(keys.a) or btn(keys.b)) then
       for i=1,#walls do
         if (
           walls[i].exists and
           not walls[i].breaking and
           player.x+16 >= walls[i].x and
           player.x <= walls[i].x + 8*walls[i].w
         ) then
          if flr(abs(player.y - walls[i].y)) == 0 then
            
            -- just entered
            -- grind state
            add_to_score(
            sc.grind_start_pts)
            
            -- is a down, or is it
            -- b?
            local adown = 
            btn(keys.a)
            
            -- initiate 
            -- grinding
            -- scoring
            -------------------
            -- reset grind ticks
            -- for this unperturbated
            -- horizontal section
            p_totalgrindt = 0
            
            -- if grinding on the
            -- opposite side as
            -- last time...
            if (adown and  
            p_last_grind == 'b') or
            (adown == false and
            p_last_grind == 'a') 
            then
             p_grindinterval = 
             sc.interval_alt
            else
             -- reset fully
             p_grindt = 0
             p_grindinterval = 
             sc.interval_base
            end
            ---------------------
            
            p_last_grind =
             adown and 'a' or 'b'
             
            p_state = states.grind
            player.y = walls[i].y
            player.dy = 0
            play_snd(snd.grind)

          end
          current_wall = walls[i]
          break
         end
       end
     end
   end
  elseif ps == states.grind then
   -- prove me wrong!
   local player_should_fall = true

   for i=1,#walls do
    if (
     walls[i].exists and
     not walls[i].breaking and
     player.x >= walls[i].x and
     player.x <= walls[i].x + 8*walls[i].w
    ) then
     if flr(abs(player.y - walls[i].y)) == 0 then
      player_should_fall = false
     end
     break
    end
   end

   if player_should_fall then
    -- fallllllllllllllll
    p_state = states.jump
    if sc.destroy_on_fall then
     check_for_destruction()
    end
   else
   
    -- continuous grinding!!
    ------------------
    if p_totalgrindt < 
    sc.max_grind_ticks then
     p_grindt += 1
     p_totalgrindt += 1
     if p_grindt>=p_grindinterval
    	then
     	add_to_score(1)
     	p_grindt = 0
     	p_grindinterval =
      	max(p_grindinterval-
      	sc.interval_drop_rate,
      	sc.interval_min)
    	end
    end
    ------------
    check_for_jump()
   end
  elseif ps == states.down then
   -- todo: special handling ?
  else  -- states.land
   if (
    t - land_t >= land_time
   ) then
    p_state = states.idle
   end
  end

  if (
   p_state == states.launch or
   p_state == states.jump or
   p_state == states.down
  ) then
   local py_before = p.y
   if apply_gravity(p) then
    if (
     current_wall and
     (btn(keys.a) or btn(keys.b)) and
     py_before < current_wall.y and
     p.y > current_wall.y
    ) then
     -- oops we just passed through
     -- the wall while holding the button!
     -- reset player on wall so grinding
     -- works on next turn
     p.y = current_wall.y
   end
   else
    -- just landed
    p_last_grind = nil
    reset_gauge(gauge)
    p_state = states.land
    land_t = t
    play_snd(snd.skate)
   end
  end

  if (
   p_state == states.idle or
   p_state == states.crouch or
   p_state == states.land
  ) then
   player.bob_frame = flr(
  	t/idle_bob_time % 2
   )
  else
   yoffset = 0
  end

  compute_frame(p)
end

function compute_frame(p)
  local ps = p_state
  if ps == states.idle then
  	if p.bob_frame == 0 then frm = 0
   else
   frm = 6
   end
  elseif ps == states.crouch then
   frm = 1
  elseif ps == states.launch then
   if t - launch_t < 6 then
    frm = 2
   else
    frm = 3
   end
  elseif ps == states.jump then
   if btn(keys.a) then
    frm = 3
   elseif btn(keys.b) then
    frm = 5
   else
    frm = 4
   end
  elseif ps == states.grind then
   -- todo: handle grind
  elseif ps == states.down then
   if btn(keys.a) then
    frm = 3
   else
    frm = 5
   end
  else -- ps == states.land
   frm = 1
  end

  p.frame = 80+2*frm
  p.framew = 2
  p.frameh = 3
end

-- returns false if no effect,
-- else true
function apply_gravity(p)
  p.dy += p.ddy
  p.y += p.dy
  if (p.y >= ground_y) then
    -- we are on the ground
    p.y = ground_y
    p.dy = 0
    return false
  end
  return true
end


function drawskater(p)
	spr(
   p.frame,
   p.x,
   p.y - playerheight,
   p.framew,
   p.frameh
  )
end

function reset()
 --------------
 frm = 0
 launch_t = nil
 land_t = nil
 p_state = states.idle
 lastwall = nil
 start_countdown = nil
 --------------------
 t = 0
 score = 0
 game_started = false
 timer = game_duration
 p_last_grind = nil
 set_gauge_value(gauge,0)
 player.y = ground_y
 -- title music
 music(14)
 walls = {}
end

function _init()
  
  game_over = false
  
  player = make_player(8, ground_y)
  
  gauge = make_gauge(
   8,64,0,119)

  gauge.x = 64-gauge.width/2

  palt(0,false)
  palt(7,true)
  
  reset()
end

function make_gauge(
width_in_sprites,
max_value,
x,y)

	width_in_sprites = max(
	 3,width_in_sprites)
	 
	local width =
	 width_in_sprites * 8
  
 -- create gauge object
 gauge={
 	w=w,
 	x=x,
 	y=y,
 	width=width,
 	width_in_sprites=
 	 width_in_sprites,
 	pixels_per_unit=
 	 width/max_value,
 	max_value=max_value,
 	value=0,
 	multiplier=1,
 	maxed=false
 }
 
 set_gauge_value(gauge,units)
 
 return gauge
end

function reset_gauge(gauge)
 set_gauge_value(gauge,0)
end

function set_gauge_value(
gauge,value)
 gauge.value = min(
  gauge.max_value,value)
 gauge.maxed = gauge.value==
  gauge.max_value 
 local mult =
 flr(4*(gauge.value/
 gauge.max_value))+1
 mult = min(mult,4)
 gauge.multiplier = mult
end

function draw_gauge(gauge)

 local x = gauge.x
 local y = gauge.y
 local col = 7+gauge.multiplier
 
 local flasht 
 local gaugecol
 local textcol
 
 if gauge.maxed then
  col = 2
 	-- zero or one
  flasht = flr((t%16)/8)
  gaugecol = flasht == 0 and 7 or 0
  textcol = flasht == 0 and 0 or 7
  pal(2,gaugecol)
 end
 
 -- left cap
 spr(70,x-1,y)
 for i=0,
 gauge.width_in_sprites-1 do
  spr(71,x+i*8,y)
 end
 -- right cap
 spr(70,x+gauge.width,y)

 -- draw the gauge's inside
 if gauge.value > 0 then
  local inner_height=6
  rectfill(
   x,
   y+1,
   x+gauge.pixels_per_unit*
    gauge.value-1,
   y+inner_height,
   col
  )
 end
 
 if gauge.maxed then
  local text = "bring it down!"
  print(
   text,
   x+gauge.width/2-
    (#text/2)*4,
   y+1,
   textcol
  )
  -- reset
  pal(2,2)
 else
  -- separators
  spr(70,x+gauge.width*0.25,y)
  spr(70,x+gauge.width*0.5,y)
  spr(70,x+gauge.width*0.75,y)
 end
 
end

function add_wall(x,w,h)
	local wall = nil
	for i=1,#walls do
 	if not walls[i].exists then
			wall = walls[i]
			break
		end
	end
	if wall == nil then
		wall = {}
		walls[#walls+1] = wall
	end
	wall.x = x
	wall.y = 112-h*8
	wall.w = w
	wall.h = h
	wall.anim_x = 0
	wall.anim_y = 0
	wall.anim_elapsed = 0
	wall.exists = true
	wall.breaking = false
	wall.posters = {}
	wall.barbwire = {}
	wall.explosions = {}
	wall.rubble = {}
	
	-- add barbwire (or not)
	if rnd(1) < 0.2 then
		local numbarbs =
		 min(4,2+flr(rnd(w-4+1)))
		local barbstart =
			1+flr(rnd(w-numbarbs+1))
	 for i=1,w do
	  wall.barbwire[i] =
	  	i >=barbstart and
	  	i < barbstart+numbarbs
	 end
	end
	
	-- add propaganda
	-- cycle through every poster
	-- model and do a random check
	-- to post it on the wall
	for i=1,#posters do
		local p = posters[i]
		if w >= p.w+2 and
		h >= p.h+2 then
			if rnd(1)<0.3 then
				wall.posters[
				#wall.posters+1]=
				{
					i=p.i,w=p.w,h=p.h,
					x=8+rnd(8*(w-p.w-2)),
					y=8+rnd(8*(h-p.h-2))
				}
				break
			end
		end
	end
	lastwall = wall
	return wall
end

function break_all_walls()
	for i=1, #walls do
		break_wall(walls[i])
	end
end

function break_wall(wall)
	if not wall.exists or
	wall.breaking then 
		return
	end
	wall.breaking = true
	wall.anim_elapsed = 0
	for i=1, wall.w do
		wall.explosions[i] = 
		 -4-flr(rnd(4))
		wall.rubble[i] = 
		 rubble[1+flr(rnd(3))]
	end
	play_snd(snd.explode)
end

function update_wall(wall)
	if not (wall.exists and
	game_started) then
		return
	end
	if wall.breaking then
		wall.anim_elapsed += 1
		wall.anim_x = 
		 rnd(6)-3
		wall.anim_y = 
		 (wall.anim_elapsed/4)*
		 (wall.anim_elapsed/4)+
		 rnd(2)-1
	end
	wall.x -= scroll_speed
	if wall.x+wall.w*8 < -16 then
		wall.exists = false
	end
end

function draw_wall(wall)
	if not wall.exists then
		return
	end
	local x = wall.x+
	 wall.anim_x
	local y = wall.y+
	 wall.anim_y
	local indexes = {1,17,33,49}
	local col_index = 0
	
	for i=1, wall.w do
		if i == wall.w then 
		 col_index = 2
		elseif i > 1 then 
		 col_index = 1
		end
		local row_index = 1
		for j=1, wall.h do
			if j == wall.h then
			 row_index = 4
			elseif j == wall.h-1 then
			 row_index = 3
			elseif j > 1 then
			 row_index = 2
			end
			-- draw 1x1 wall sprite
			-- at i,j
			spr(
				indexes[row_index]+col_index,
				x+(i-1)*8,y+(j-1)*8)
		end
		
		-- draw barbwire
		if wall.barbwire[i] then
		 spr(52,x+(i-1)*8,y-8)
		end
		
		-- draw rubble
		if wall.breaking then
			-- total animation time in frames
			-- of the corresponding explosion
			-- if at least past a certain point,
			-- reveal the rubble
 		local xplo_frames =
				flr(wall.anim_elapsed/
				4+wall.explosions[i])
 		if xplo_frames >= 2 then
 			local rubble = 
 			wall.rubble[i]
 			spr(
 				rubble.i,
 				wall.x+(i-0.5-rubble.w/2)*8,
 				wall.y+(wall.h-rubble.h)*8,
 				rubble.w,
 				rubble.h
 			)
 		end
		end
	end
	
	palt(7,false)
	palt(0,true)
	-- draw propaganda
	for i=1, #wall.posters do
		local p = wall.posters[i]
		spr(p.i,x+p.x,y+p.y,p.w,p.h)
	end
	palt(0,false)
 palt(7,true)
end

function draw_wall_explosions(
wall)
	if not wall.exists then
		return
	end
	if wall.breaking then
  palt(0,true)
  palt(7,false)
  -- explosion duration
  -- in frames
  local xplo_duration = 4
  for i=1,wall.w do
  	-- total elapsed animation
  	-- frames
  	local xplo_frames =
				flr(wall.anim_elapsed/4+
				wall.explosions[i])
  	-- current frame index
  	local xplo_curframe =
				xplo_frames%xplo_duration
  	-- plays explosion anim only 2 times
  	if xplo_frames >=0 and
				xplo_frames < 
				xplo_duration*1 and
				xplo_curframe >= 0 and
				xplo_curframe <= 3 then
  			local sprite_index=
						explosion_frames[
						xplo_curframe+1]
  			spr(
  				sprite_index,
  				wall.x+(i-1)*8-4,
  				wall.y+(wall.h-2)*8,
  				2,
  				2
  			)
  		end
  	end
  palt(0,false)
  palt(7,true)
	end			
end

function drawscrollmap(
s,mx,my,x,y,w,h)
		tx = flr(s/8)%w
  dx = -(s%8)
  mapdraw(mx+tx,my,dx,y,w-tx,h)
  mapdraw(mx,my,(w-tx)*8+dx,y,tx+1,h)
end

function is_a_wall_moving()
 for i=1, #walls do
  local wall = walls[i]
  if (
    wall.exists and
    wall.breaking and
    wall.y + wall.anim_y <
     ground_y + 60
  ) then
   return true
  end
 end
 return false
end

function draw_title()
 if t > 60 then
  return
 end

 local wall_anim_y =
 	flr((t/4)*(t/4))
 local wall_y =
  -- apply gravity at start
  title_wall_y+wall_anim_y
 
 local logo_t = max(0,t-5)
 local logo_anim_y =
 	flr((logo_t/4)*(logo_t/4))
	local logo_x = 13
	local logo_y = 12+logo_anim_y

 -- wall in foreground
 map(0,17,-1,wall_y,18,15)
 
 local border_offset_x = 42
 local border_offset_y = 26
 
 -- logo
 spr(162,logo_x,logo_y,7,6)
 spr(201,
 logo_x+border_offset_x,
 logo_y+border_offset_y,
 3,3)
 spr(171,
 logo_x+border_offset_x+16,
 logo_y+border_offset_y-16,
 5,4)

 local message =
   '  press ❎ to start'
 local blink = true
 if (
  start_countdown or
  game_started
 ) then
  message =
   'let\'s wreck that wall!'
  blink = false
 end
 if (
  not blink or
  flr(time()) % 2 == 0
 ) then
  print(
   message,
   8*2.5,
   8*13+wall_anim_y,
   7
  )
 end
end

function draw_wall_outline(wall)
  local width = 8*wall.w
  local height = 8*wall.h
  if (
    wall.exists and
    not wall.breaking
    and player.x >= wall.x
    and player.x <= wall.x + width
  ) then
    line(wall.x, wall.y, wall.x, wall.y + height, 11)
    line(wall.x, wall.y, wall.x + width, wall.y, 11)
    line(wall.x, wall.y + height, wall.x + width, wall.y + height, 11)
    line(wall.x + width, wall.y, wall.x + width, wall.y + height, 11)
  end
end

function print_debug_messages()
  local debug_messages = {
    "walls: "..tostr(#walls),
    "player: ("..tostr(player.x)..", "..tostr(player.y)..")",
    "player state: "..tostr(p_state)
  }
  for i=1,#debug_messages do
    print(debug_messages[i], 1, (i-1)*6 + 16, 1)
  end
end

function _draw()
  local cam_x = 0
  local cam_y = 0
  if is_a_wall_moving() then
   cam_x =
    flr(-1 + rnd(5))
   cam_y =
    flr(-1 + rnd(3))
  end
  camera(cam_x, cam_y)
		
		--s is the amount of scrolling
	 local s = t*scroll_speed
  cls()
  --sky
  rectfill (-8,-8,127+8,127+8,12)
  --cloud
  palt(0,true)
  palt(7,false)
  local cloudx
  cloudx= 130-((t+5000)/64)%180
  spr(76,cloudx,16,4,1)
  cloudx= 130-((t+1000)/72)%180
  spr(76,cloudx,24,4,1)
  palt(0,false)
  palt(7,true)
  -- far far mountains
  drawscrollmap(s/200,32,2,-8,4*8+3,24,2)
  --mapdraw(32,2,0,4*8+3,32,2)
  -- background
  drawscrollmap(s/8,32,5,-8,5*8+3,24,2);
  drawscrollmap(s/4,32,7,-8,7*8,24,2);
  drawscrollmap(s/2,32,9,-8,9*8,24,5);

  --walls
  for i=1, #walls do
  	draw_wall(walls[i])
    if debug then
      draw_wall_outline(walls[i])
    end
  end
  for i=1, #walls do
  	draw_wall_explosions(walls[i])
  end

  -- foreground
  drawscrollmap(s,0,14,-8,14*8,18,3)
  drawskater(player)
 
 -- lyric cursor
  local lc =
    --(t-lst)%(let-lst) + lyric_t_offset
    (t-lst)+lyric_t_offset //verse 1 only

  for _,lyric in pairs(lyrics)
  do
    for _,off in pairs(lyric[3])
    do
      if
        lc >= lyric[2][1] + off and
        lc < lyric[2][2] + off then
          text = lyric[1]
          print(
            text,
            8*8 - (#text*4)/2,
            8,
            7
          )
          break
      end
    end
  end
  
  ------------------------
  -- u.i ☉☉
  ------------------------
  
  -- gauge
  draw_gauge(gauge)
  
  -- score
  local text = tostr(score)
  print(text,
   gauge.x+gauge.width+4
   ,121,0)
  
  -- timer
  spr(53,2,121-2)
  text = tostr(timer)
  print(text,12,121,0)

  if debug then
    print_debug_messages()
  end

  -- layer title screen on top
  draw_title()
  
  -- game over screen
  --draw_game_over()
end

function _update60()
  if (
   start_countdown and
   not game_started
  ) then
   if btn(keys.a) or btn(keys.b) then
    -- make sure player is ready
    -- to launch on game start
    p_state = states.crouch
   end

   start_countdown -= 1
   if start_countdown == 0 then
    game_started = true
    music(0)
    play_snd(snd.skate)
   end
  end

  if (
   not game_started and
   not start_countdown and
   (btn(keys.a) or btn(keys.b))
  ) then
   -- wait 400 ms before
   -- starting game
   start_countdown = start_delay
   music(-1)
   play_snd(43)
  end

  update_player(player)
  
  for i=1, #walls do
  	update_wall(walls[i])
  end
  
  if lastwall == nil or
  	lastwall.x+lastwall.w*8 <= 
  	128
  then
  	local wallx = 128
  	if lastwall then
  		wallx = flr(lastwall.x+
  		lastwall.w*8)
  		if rnd(1) < 0.1 then
  		 wallx += flr(rnd(64))
  		end
  	end
  	add_wall(wallx,4+flr(rnd(8)),
  	5+flr(rnd(5)))
  end

  if game_over then
   if go_transition_in then
    if go_colindex >= 0 then
     pal(go_colindex,0)
     go_colindex -= 1
    elseif go_t == 45 then
     go_transition_in = false
     go_colindex = 15
     reset()
    end
   else --transition out
    if go_colindex >=0 then
     pal(go_colindex,go_colindex)
     go_colindex -= 1
    else
     game_over = false
    end 
   end
   go_t += 1
  end
  
  if game_started 
  then
   if t%60 == 0 then
    timer -= 1
    if timer == 0 then
     go_t = 0
     go_colindex = 15
     go_transition_in = true
     game_over = true
     game_started = false
     sfx(-1)
     --music(-1)
    end
   end
   t += 1
  end
end

__gfx__
00000000700000000000000000000007777777777777777777777777777777771111111111111111111111111111111188888888888888888888888888888888
00000000056666666666666666666660777777777777777007777777777777771888888881171717171711888888888181188888888899998998888888888118
00700700015656565656565656565660777777777777770ff0777777777777771811111111111111111111111111118181888888899999999999998888888818
0007700001555555555555555555556077777777777770ffff077777777777771811111111111111111111111111118188888889999444999949944888888888
000770000155555555555555555555607777777777770ffffff07777777777771811111111111111111111111111118188888899994444494944444988888888
00700700015555555555555555555560777777777770ffffffff0777777777771811117771771171717171771111118188888899944444444444449998888888
0000000001555555555555555555556077777777770ffffffffff077777777771811111711717171717771717111118188888999944444444449999999888888
000000000155555555555555555555607777777770fffff44fffff07777777771811111711771171717771771111118188888999944fffff4f49999999888888
00000000015555555555555555555560777777770fffff4444fffff077777777181111171171717771717171111111818888899444ffffffffffff9991888888
0000000001555555555555555555556077777770fffff4ffff4fffff07777777181111111111111111111111111111818888899444fffffffffffff991888888
000000000155555555555555555555607777770fffff44444444fffff077777718111177777777777777777771111181888889944444ffffffff44f991888888
00000000015555555555555555555560777770fffff4ffffffff4fffff077777181111111111111111111111111111818888899444f144ffff441f4f91188888
0000000001555555555555555555556077770fffff4ffffffffff4fffff0777718111111111111111111111111111181888889944fff144ff441ff4f11188888
000000000155555555555555555555607770fffff44444444444444fffff077718111111111111111111111111111181888889444ff171ffff171fff11188888
00000000015555555555555555555560770fffff4444444444444444fffff07718888888811717171717118888888881888844444fffff4ffffffff4ff188888
0000000001555555555555555555556070fffff444444444444444444fffff07111111111111111111111111111111118888ff4444ffff4ffffffff4f4f88888
ffffffff0155555555555555555555600fffff44444444444444444444fffff0000000000000000000000000000000008888f4f444fff4fffffffff444f88888
ffffffff015555555555555555555560fffff4444444444444444444444fffff00000000000000000000000000000000888814f444fff41ff1f4fff444f88888
ffffffff015555555555555555555560ffff444444444444444444444444ffff0000000000000000000000000000000088881f444fff4fffffff4ff44f888888
ffffffff015555555555555555555560fff44444444444444444444444444fff00000000000000000000000000000000888881ff4fffff1111fffff441888888
ffffffff015555555555555555555560ff4444444444444444444444444444ff00000000000000000000000000000000888888114ffff177771ffff418888888
4444444401555555555555555555556044444444444444444444444444444444000000000000000000000000000000008888888114fff177771ffff418888888
44444444015555555555555555555560444444444444444444444444444444440000000000000000000000000000000088888881114ffff44ffffff418888888
44444444056666666666666666666660444444444444444444444444444444440000000000000000000000000000000088888881114fffffffffff4418888888
44444444015555555555555555555560777777777700007700000000000000000000000000000000000000000000000088888881114fffffffffff4418888888
444444440155555555555555555555607770077770777707000000000000000000000000000000000000000000000000888888811144ffffffffff4418888888
4444444401555555555555555555556077077077077077700000000000000000000000000000000000000000000000008888888811441ffffffff44188888888
44444444056666666666666666666660770770770770777000000000000000000000000000000000000000000000000088888888111441111114441188888888
44444444015555555555555555555560770770770770007000000000000000000000000000000000000000000000000088888888811144444411111888888888
44444444056666666666666666666660770770770777777000000000000000000000000000000000000000000000000081888888881111111111118888888818
44444444056666666666666666666660777007777077770700000000000000000000000000000000000000000000000081188888888811111111888888888118
44444444055555555555555555555550000770007700007700000000000000000000000000000000000000000000000088888888888888888888888888888888
77700000000000777777777777777777777777777700007777777777222222227777777777777777777777777777777700000000000000000000000000000000
77066666666666077777777777777777777777777056660727777777777777777777777277777777777777777777777700000007777777777700000000000000
70155555555566607777777777777777777777770155556027777777777777777777777277777777777777777777777700000077777777777770000000000000
01555555555555607700007777777777770007770155556027777777777777777777777277777777777777777777777700000077777777777770000000000000
01555555555555507016660777000077701660770155556027777777777777777777777277777777777777777777777707777777777777777777770000000000
01555555555555500155556070166607015556070155555027777777777777777777777277777777777777777777777777777777777777777777777777777700
01555555555555500155556001556660015556077011110727777777777777777777777277777777777777777777777777777777777777777777777777777770
01555555555555500155556001555550015555077700007777777777222222227777777777777777777777777777777707777777777777777777777777777700
77777777777777777777777777777777777777777700077777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777049907777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777770000040077777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777708888807777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777708888807777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777708800007777777777000007777777777770000077777777777700000777777777777777777777777777777777777
77777700000777777777777777777777777708044407777777770888880000777777708888807777777777088888077777777777777777777777777777777777
77777088888077777777777777777777777708099077777777770888880499077777708888807777770077088888077777777700000777777777777777777777
77777088800077777777777777777777700008800077777777770880000000777777708800007777709900088000077777777088888077777777777777777777
77777088044077777777770000077777099488888077777777770804440777777777708044400000770448880444077777777088800077777777770000077777
77777708099077777777708888807777090008888077777777770809907777770000008099088990777000080990777777777088044077777777708888807777
77777708099077777777708880007777090708888000777777000880007777770994888800000007777777088000077777777708099077777777708880007777
7700000880000007777770880440777770770888d666077770448888807777777000008888077777777777088888800777777708099077777777708804407777
709948888888499077777708099077777777088d00d6000709900888807777777777708888077777777777088880099077000008800000077777770809907777
77000088880000077700000809900007777708d070d6080700070888800007777777708888007777777000088880700770994888888844907700000809900007
7777708888077777709948888008449077770d6070d0807777770dddddd6607777770ddddd660777770666ddddd0777777000088880000077099488880084490
777770888800777777000088880000077777066070080077777066d000dd6007777066d000d660777006dd000d66077777777088880777777700008888000007
77770ddddd6607777777008888000777777706607080a077777066077700088077066d07770d66070880007770d6077777770088880007777777008888000777
777066d000d66077777066ddddd66077777706600807077777706607700880077066d077770d66077008800770d66077777066d000dd6077777066ddddd66077
77066d07770d660777066dd0000d660777770660807777777706607008800a07000000000000000070a00880070d607777066d07770d660777066dd0000d6607
7066d077770d66077066d007770d660777770608077777777706600880077077088888888888888077077008800d60777066d077770d66077066d007770d6607
000000000000000000000000000000007777008077777777770008800777777770a000000000a007777777700880007700000000000000000000000000000000
08888888888888800888888888888880777088007777777777088007777777777777777777777777777777777008807708888888888888800888888888888880
70a000000000a00770a000000000a007777700a0777777777770a07777777777777777777777777777777777770a077770a000000000a00770a000000000a007
33333333333333330000000077777777777333337777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
33333333333333330000000077777773333333333337777777777777777777777777777777777777777777770000000000000000000000000000000000000000
33333333333333330000000077773333333333333333377777777777777777777777777777777777777777770000000000000000000000000000000000000000
33333333333333330000000033333333333333333333333777777777777777777777777733333333333377770000000000000000000000000000077777700000
333f3333333333330000000033333333333333333333333337777777777777777777333333333333333333330000000000000000000000000007777777777000
333333f3333333330000000033333333333333333333333333377777777777777333333333333333333333330000000000000000000000000077777777777700
3f333f33333333330000000033333333333333333333333333333777777777333333333333333333333333330000000000000000000000000077777777777700
333f3333333333330000000033333333333333333333333333333333333333333333333333333333333333330000000000000777777000000777777777777770
f3ff333fffffffffdddddddd77777777777777777777777777777777777777777777777777777777777777770000000000007777777700000777777777777770
3f33f3ffffffffffdddddddd777777777777777777777777777777777777777777777777dddd7777777777770000000000077777777770000777777777777770
f3f33f33ffffffffdddddddd77777777777777777ddddddd7777777777777777777777dddddddd77777777770000000000077777777770000777777777777770
3333f333ffffffffdddddddd77777777dddd77ddddddddddddd777777777777dddddddddddddddd7777777770000000000077777777770000777777777777770
3f3f3f33ffffffffdddddddd7777777ddddddddddddddddddddddddd77777ddddddddddddddddddd777777770000000000077777777770000777777777777770
f3f333ffffffffffdddddddd77777dddddddddddddddddddddddddddddddddddddddddddddddddddd77777770000000000077777777770000077777777777700
33333f3fffffffffdddddddd77dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77770000000000077777777770000077777777777700
333f333fffffffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000007777777700000007777777777000
ffff3f3fffffffff7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
fff3f333ffffffff7777777777777777777777770077777777777777777777777777777777777777777777777777777777777777777777777880777777777777
ff3333f3ff3f3fff777777777777777777777770aa07777777777777777777777777777777777777777777777777777777777777777777778078077777777777
f3f3333ff3f333ff77777777777777777777770aaaa0777777700000007777777777777777777777777777777777777777777777777777780778077777777777
3f333fffff333f3f77777777770000007777770aaaa077777000aaaaa00077777777777777777777777777777777777777777777777777780778077777777777
f333f3fff3f333ff77777777000aaaa00077700aaaaa077700aaaaaaaaa007777777777777777777777777777777777777777777777807807780777777777777
3f333ffff33d333f777777000aaaaaaaa00770aaaaaa07770aaaaaaaaaaa00777777777777777777777777777777777777777777778077807807777777777777
33d333ffffffffff7777700aaaaaaaaaaaa0709aaaaa00700aaaaaaaaaaaa0077777777777777777777777777777777777777777780777808077777777777777
ff3ff3ffff3f3f3f777700aaaaaaaaaaaaaa009aaaaaa0709aaaaaaaaaaaa0007777777777777777777777777777777777777778807777880777777777770077
3ff3333ff3f333f377770aaaaaaaaaaaaaaaa049aaaaa0009aaaaaaaaaaa99007777777777777777777777777777777777880778077780807777777777708077
f33f33f33f33f33f77700aaaaaaaaaaaaaaaaa099aaaa0049aaaaaaaaa9999007777777777777777777777777788807778078078077807880777777777088077
3f33f33ff3f33d337770aaaaaaaaaaaaaaaaa99099aa990499aaaaa0099999007777777777777777777777777807780780778078088077808077777770886077
333f3d33333f33f37770aaaaaaaaaaaaaaa999904999990499000a00009999007777777777777777777777777807780780778078807780807807777708860077
3f3333f3f33d333f7770aaaaaaaaaaaaa99999990999990490999007709999007777777777777777777777777807780780778078077807807780770088600777
f33d333f3ff3df3f7770aaaaaaaaaaa9999999990499990409999077709990077777777777777777777777777807780780778078078077777777008866007777
3ffddff3ffffffff7770aaaaaaaaa999999999999099990099999077099990077777777777777777777777777807780780780778080777777700886600077777
77777777777777777770aaaaaaa99999999999999049990099999000999900777777777777778880777778807807807780780778807777770088660000077777
777777777777777777700aaaa9999999999999999909900999999099999900007777777777780778077780780808077780807778077777008866000000007777
777777777777777777770aa999999990999999999909900999999099999999900077777777807778077807780807807780807777777700886600007000007777
7777777777777777777700999999999900999999990990999999009999999999900777777880778077780778080778078807777777008866000077099a007777
7777777777777777777700999999999990000999900990999999049000999999990077777880778077807778080777808807777700886600007777094a077777
77777777777777777777700999999999990000000049909999990400000999999900777780807807778077807807777780777700886600007777770aaa077777
77777777777777777777700099999999999900004449999999900400770099994440077780808888808077807807777780770088660000777777777000777777
77777777777777777777770009999999999990044499999999904907777099444440077777888807788077807777777777008866000077777777777777777777
77777777777777777777777000099999999999004999999999004907777044444440077777807777788078077777777700886600007777777777777777777777
77777777777777777777777700000999999999900499999990049990777044444440077778807777780880777777770088660000777777777777777777777777
77777777777777777777777777000009999999990499999900449944000444444440077778807777807777777777008866000077777777777777777777777777
77777777777777777777777700000000000999990049999990444444444444444440077780807777807777777700886600007777777777777777777777777777
77777777777777777777770099999990009999999049999999044444444444444400077777807778077777770088660000777777777777777777777777777777
77777777777777777777009999999999909999999009909999904444444444444400077777807780777777008866000077777777777777777777777777777777
77777777777777777770099999999999990999999909990999440444444444444000777777807807777700886600007777777777777777777777777777777777
77777777777777777700999999999999999999994400990044444044444444440000777777808077770088660000777777777777777777777777777777777777
77777777777777777700999999999999999999444440999004444404444444000007777777880777008866000077777700000000000000000000000000000000
77777777777777777009999999999999999944444440944000044440000000000077777778077700886600000777777700000777777000000000077777700000
77777777777777777009999999999999994444444440444000000440000000000777777777770088660000000077777700077777777770000007700000077000
77777777777777777009999999999999444444444440444400000000000000077777777777708866000070000077777700777777777777000070000000000700
777777777777777770099999999999444444444444404444007000000777777777777777770866000077099a0077777707777000000777700700000000000070
777777777777777770009999999944444444444444004444007770007777777777777777770600007777094a0777777707770000000077700700000000000070
7777777777777777770099999944444444444444440044440077777777777777777777777700007777770aaa0777777777700000000007777000000000000007
77777777777777777700099944444444444444444000444400777777777777777777777777777777777770007777777777700000000007777000000000000007
77777777777777777770004444444444444444444000044000777777777777777777777777777777777777777777777777000000000000777000000000000007
77777777777777777770000444444444444444440000000007777777777777777777777777777777777777777777777777000000000000777000000000000007
77777777777777777777000044444444444444400007000077777777777777777777777777777777777777777777777777000000000000777000000000000007
77777777777777777777700000444444444440000077777777777777777777777777777777777777777777777777777777000000000000777000000000000007
77777777777777777777770000000444444000000777777777777777777777777777777777777777777777777777777777700000000007777000000000000007
77777777777777777777777000000000000000007777777777777777777777777777777777777777777777777777777707700000000007700700000000000070
77777777777777777777777770000000000000777777777777777777777777777777777777777777777777777777777707770000000077700700000000000070
77777777777777777777777777770000000077777777777777777777777777777777777777777777777777777777777700777000000777000070000000000700
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccc0aa0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccc0aaaa0ccccccc0000000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccc000000cccccc0aaaa0ccccc000aaaaa000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc7777000aaaa000ccc00aaaaa0ccc00aaaaaaaaa00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc777000aaaaaaaa00cc0aaaaaa0ccc0aaaaaaaaaaa00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc7700aaaaaaaaaaaa0c09aaaaa00c00aaaaaaaaaaaa00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc77777700aaaaaaaaaaaaaa009aaaaaa0c09aaaaaaaaaaaa000ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc77777770aaaaaaaaaaaaaaaa049aaaaa0009aaaaaaaaaaa9900ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccc77777700aaaaaaaaaaaaaaaaa099aaaa0049aaaaaaaaa999900ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccc777770aaaaaaaaaaaaaaaaa99099aa990499aaaaa009999900ccccccccccccccccccccccccccccccccccc880ccccccccccccccccccccccccccccc
cccccccccccccccc0aaaaaaaaaaaaaaa999904999990499000a0000999900cccccccccccccccccccccccccccccccccc80c80cccccccccccccccccccccccccccc
cccccccccccccccc0aaaaaaaaaaaaa9999999099999049099900cc0999900ccccccccccccccccccccccccc77777777807c80cccccccccccccccccccccccccccc
cccccccccccccccc0aaaaaaaaaaa99999999904999904099990ccc099900ccccccccccccccccccccccccc777777777807780cccccccccccccccccccccccccccc
cccccccccccccccc0aaaaaaaaa9999999999990999900999990cc0999900ccccccccccccccccccccccccc77777807807780ccccccccccccccccccccccccccccc
cccccccccccccccc0aaaaaaa99999999999999049990099999000999900ccccccccccccccccccccc777777777807780780777ccccccccccccccccccccccccccc
cccccccccccccccc00aaaa999999999999999990990099999909999990000cccccccccccccccccc777777777807778080777777777777ccccccccccccccccccc
ccccccccccccccccc0aa9999999909999999999099009999990999999999000cccccccccccccccc7777777880777788077777777777007cccccccccccccccccc
ccccccccccccccccc00999999999900999999990990999999009999999999900cccccccccccccccc78807780777808077777777777080ccccccccccccccccccc
ccccccccccccccccc009999999999900009999009909999990490009999999900cccccccc8880ccc80c80c80cc80c880ccccccccc0880ccccccccccccccccccc
cccccccccccccccccc00999999999990000000049909999990400000999999900ccccccc80cc80c80cc80c80880cc8080ccccccc08860ccccccccccccccccccc
cccccccccccccccccc00099999999999900004449999999900400cc00999944400cccccc80cc80c80cc80c880cc8080c80ccccc088600ccccccccccccccccccc
ccccccccccccccccccc000999999999999004449999999990490cccc0994444400cccccc80cc80c80cc80c80cc80c80cc80cc0088600cccccccccccccccccccc
cccccccccccccccccccc00009999999999900499999999900490cccc0444444400cccccc80cc80c80cc80c80c80cddddccc00886600ccccccccccccccccccccc
ddddccccccccccccccccc00000999999999900499999990049990ccc0444444400ddcccc80cc80c80c80cc8080ddddddd008866000cccccccccccccccccccddd
dddddddccccccccccccdddd0000099999999904999999004499440004448880400dd880c80c80cc80c80dd880dddddd00886600000ccccccccccddddccdddddd
ddddddddddddcccccdddd000000000009999900499999904444444444480448000d80d808080ccc8080ddd80ddddd00886600000000ccccccccddddddddddddd
ddddddddddddddddddd0099999990009999999049999999044444444480444800080008080080dd8080dddddddd0088660000c00000ccccccddddddddddddddd
ddddddddddddddddd0099999999999099999990099099999044444448804480000806680806680d880ddddddd0088660000dd099a00cccdddddddddddddddddd
dddddddddddddddd009999999999999099999990999099944044444488044800080565808066080880ddddd0088660000dddd094a0dddddddddddddddddddddd
ddddddddddddddd00999999999999999999994400990044444044448080480000805580580560dd80dddd00886600003ddddd0aaa0dddddddddddddddddddddd
ddddddddddddddd00999999999999999999444440999004444404448080888880805580580560dd80dd0088660000333333ddd000ddddddddddddddddddddddd
dddddddddddddd009999999999999999944444440944000044440000088880058805580555560dddd00886600003333333333ddddddddddddddddddddddddddd
333333333333dd009999999999999994444444440444000000440000080000558805805555560dd008866000033333333333333ddddddddddddddddddddddddd
333333333333330099999999999994444444444404444000000000008800555580880555555600088660000333333333333333333ddddddddddddddddddd3333
33333333333333009999999999944444444444440444400500000055880555580555555555500886600003333333333333333333333dddddddddddddd3333333
3333333333333300099999999444444444444440044440055500055808055558055555555008866000033333333333333333333333333ddddddddd3333333333
33333333333333300999999444444444444444400444400555555555580555805555555008866000033333333333333333333333333333333333333333333333
33333333333333300099944444444444444444000444400555555555580558055555500886600003333333333333333333333333333333333333333333333333
33333333333333330004444444444444444444000044000555555555580580555550088660000333333333333333333333333333333333333333333333333333
33333333333330000000444444444444444440000000005555555555580805555008866000060333333333333333333333333333333333333333333333333333
33333333333308888000044444444444444400005000055555555555588055500886600005560333333333333333333333333333333333333333333333333333
33333333333308888800000444444444440000055555555555555555805550088660000055560333333333333333333333333333333333333333333333333333
33333333333308800000000000444444000000555555555555555555555008866000000005560333333333333333333333333333333333333333333333333333
33333333333308044403000000000000000005555555555555555555550886600005000005560333333333333333333333333333333333333333333333333333
3333333333330809903330000000000000055555555555555555555550866000055099a005560333333333333333333333333333333333333333333333333333
3333333333000880003330155000000005555555555555555555555550600005555094a055560333333333333333333333333333333333333333333333333333
3333f333304488888033f01555555555555555555555555555555555500005555550aaa0555603333333f3333333f3333333f3333333f3333333f3333333f333
3333333f09900888803330155555555555555555555555555555555555555555555500055556033f3333333f3333333f3333333f3333333f3333333f3333333f
33f333f30003088880000015555555555555555555555555555555555555555555555555555603f333f333f333f333f333f333f333f333f333f333f333f333f3
3333f33333330dddddd66015555555555555555555555555555555555555555555555555555603333333f3333333f3333333f3333333f3333333f3333333f333
ff3ff333ff3066d000dd600555555555888888888888888888888888888888885555555555560333ff3ff333ff3ff333ff3ff333ff3ff333ff3ff333ff3ff333
f3f33f3ff3f0660ff300088055555555811888888888999989988888888881185555555555560f3ff3f33f3ff3f33f3ff3f33f3ff3f33f3ff3f33f3ff3f33f3f
3f3f33f33f30660330088005555555558188888889999999999999888888881855555555555603f33f3f33f33f3f33f33f3f33f33f3f33f33f3f33f33f3f33f3
33333f333306603008800a0555555555888888899994449999499448888888885555555555560f3333333f3333333f3333333f3333333f3333333f3333333f33
33f3f3f3330660088003f015555555558888889999444449494444498888888855555555555603f333f3f3f333f3f3f333f3f3f333f3f3f333f3f3f333f3f3f3
ff3f333fff0008800f3f30155555555588888899944444444444449998888888555555555556033fff3f333fff3f333fff3f333fff3f333fff3f333fff3f333f
f33333f3f3088003f3333015555555558888899994444444444999999988888855555555555603f3f33333f3f33333f3f33333f3f33333f3f33333f3f33333f3
f333f333f330a033f333f0155555555588888999944fffff4f499999998888885555555555560333f333f333f333f333f333f333f333f333f333f333f333f333
00000000000000000000f015555555558888899444ffffffffffff99918888885555555555560f00000000000000000000000000000000000000000000000000
666666666666666666660015555555558888899444fffffffffffff9918888885555555555560056666666666666666666666666666666666666666666666666
65656565656565656566001555555555888889944444ffffffff44f9918888885555555555560015656565656565656565656565656565656565656565656565
555555555555555555560015555555558888899444f144ffff441f4f911888885555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555888889944fff144ff441ff4f111888885555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555888889444ff171ffff171fff111888885555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555888844444fffff4ffffffff4ff1888885555555555560015555555555555555555555555555555555555555555555555
555555555555555555560015555555558888ff4444ffff4ffffffff4f4f888885555555555560015555555555555555555555555555555555555555555555555
555555555555555555560015555555558888f4f444fff4fffffffff444f888885555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555888814f444fff41ff1f4fff444f888885555555555560015555555555555555555555555555555555555555555555555
5555555555555555555600155555555588881f444fff4fffffff4ff44f8888885555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555888881ff4fffff1111fffff4418888885555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555888888114ffff177771ffff4188888885555555555560015555555555555111111111111111111111111111111115555
555555555555555555560015555555558888888114fff177771ffff4188888885555555555560015555555555555188888888117171717171188888888815555
5555555555555555555600155555555588888881114ffff44ffffff4188888885555555555560015555555555555181111111111111111111111111111815555
5555555555555555555600155555555588888881114fffffffffff44188888885555555555560015555555555555181111111111111111111111111111815555
5555555555555555555600155555555588888881114fffffffffff44188888885555555555560015555555555555181111111111111111111111111111815555
55555555555555555556001555555555888888811144ffffffffff44188888885555555555560015555555555555181111777177117171717177111111815555
555555555555555555560015555555558888888811441ffffffff441888888885555555555560015555555555555181111171171717171777171711111815555
55555555555555555556001555555555888888881114411111144411888888885555555555560015555555555555181111171177117171777177111111815555
55555555555555555556001555555555888888888111444444111118888888885555555555560015555555555555181111171171717771717171111111815555
55555555555555555556001555555555818888888811111111111188888888185555555555560015555555555555181111111111111111111111111111815555
55555555555555555556001555555555811888888888111111118888888881185555555555560015555555555555181111777777777777777777711111815555
55555555555555555556001555555555888888888888888888888888888888885555555555560015555555555555181111111111111111111111111111815555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555181111111111111111111111111111815555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555181111111111111111111111111111815555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555188888888117171717171188888888815555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555111111111111111111111111111111115555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
66666666666666666666005666666666666666666666666666666666666666666666666666660056666666666666666666666666666666666666666666666666
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
66666666666666666666005666666666666666666666666666666666666666666666666666660056666666666666666666666666666666666666666666666666
55555555555555555556001555555555555555555555555555555555555555555555555555560015555555555555555555555555555555555555555555555555
66666666666666666666005666666666666666666666666666666666666666666666666666660056666666666666666666666666666666666666666666666666
66666666666666666666005666666666666666666666666666666666666666666666666666660056666666666666666666666666666666666666666666666666
55555555555555555555005555555555555555555555555555555555555555555555555555550055555555555555555555555555555555555555555555555555
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444442222222222222222222222222222222222222222222222222222222222222222222222222222224444444444444444444444444
44444444444444444444444429999999999999999999999999999994444444444444444444444444444444444444444444444442444444444444444444444444
44444444444444444444444429999999999999999999999999999994444444444444444444444444444444444444444444444442444444444444444444444444
44444444444444444444444429999999999999999999999999999994444444444444444444444444444444444444444444444442444444444444444444444444
44444444444444444444444429999999999999999999999999999994444444444444444444444444444444444444444444444442444444444444444444444444
44444444444444444444444429999999999999999999999999999994444444444444444444444444444444444444444444444442444444444444444444444444
44444444444444444444444429999999999999999999999999999994444444444444444444444444444444444444444444444442444444444444444444444444
44444444444444444444444442222222222222222222222222222222222222222222222222222222222222222222222222222224444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000828282828282828282828282828282828200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000939495969798999a939495969798999a939495969798999a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000929292929292929292929292929292929292929292929292000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020202020300000000000000000000000000000000000000000000000000838485868788898a838485868788898a838485868788898a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121300000000000000000000000000000000000000000000000000818181818181818181818181818181818181818181818181000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121301020202030000000000000000000000000000000000000000808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121311121212130000000000000000000000000000000000000000909090909090909090909090909090909090909090909090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121311121212130000000000000000000000000000000000000000a1a0a1a0a1a0a1a0a1a1a0a1a0a1a0a1a1a1a0a1a0a1a0a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121311121212130000000000000000000000000000000000000000b0b091b1b0b091b1b0b091b1b0b091b1b0b091b1b0b091b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1112121212121311121212130000000000000000000000000000000000000000b091b091b091b091b091b091b091b091b091b091b091b091000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2122222222222321222222230000000000000000000000000000000000000000919191919191919191919191919191919191919191919191000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3132323232323331323232330000000000000000000000000000000000000000919191919191919191919191919191919191919191919191000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
01040000072500c250072500c25000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000047500005004750000503475000050347500005024750247500005014700147500005014750000500475000050047500005034750000503475000050247502475000050147001475000050147500005
01100000182511825118251182511b2511b2511b2511b2511b2511b2511b2511b2511b2511b2511b2511b250182511825118251182511e2511e2511e2511e2511e2511e2511e2511e2511e2511e2511e2511e250
011000001b2511b2511b2511b2512225122251222512225122251222512225122251222512225122251222501d2551e2551e2002b8751f2001f2551f2551f2551d2551e2551e2002b8751f2001e2551d2551b255
011000000047500005004750000503475034050347500005024750247500005014700147500005014750000500475064750640007475034050000503405000050547506475064000747507400064750547503475
011000000047500005004750000503475034050347500005024750247502405014700147501400014050140500475000050047500005034750000503475000050247502475000050147501405064700647006470
01100000074750c000074750000508475000050747500005084750647500005074700747500005014750000508475064750020007475130000747507400004750040502404000050147001470014700147001470
0110000018250182001b2501b2001f250182001820018200202501e250182001f25018200182001820018200202501e250182001f25018200182001820018200202501e250182001f2501f200308501d20030850
01100000182001820018250182001b2501b2001f25018200202501e250182001f25018200182001820018200202501e250182001f25018200172501820018250202001e200182001f2001f200242001d20024200
011000000747500005074750000508475000050747500005084750647500005074700747500005014750000508475064750020007475002000747500200004750240002400000000140001400000000140020200
010800002e2422b24228242252422e2422b24228242252422e2422b24228242252422e2422b24228242252422e2422b24228242252422e2422b24228242252422e2422b24228242252422e2422b2422824225242
010800002d2422a24227242242422d2422a24227242242422d2422a24227242242422d2422a24227242242422c2222922226222232222c2222922226222232222c2222c20226200232002c200292002620023200
010800201647513475104750d4751647513475104750d4751647513475104750d4751647513475104750d4751647513475104750d4751647513475104750d4751647513475104750d4751647513475104750d475
0108000015465124650f4650c46515465124650f4650c46515465124650f4650c46515465124650f4650c46514455114550e4550b45514455114550e4550b4551440011400014700147001470014700147001470
011000001830018300183501b3501e3501f3501830018300183501b3501e3501f35018300183001830018300183001b300183501b3501e3501f3501d3501b3501d3501e300183001f3001f300183001d30018300
01100000183001830017350183501a3501d350183001830017350183501a3501d350183001830018300183001e3501f3501e3501f3501e3501d3501b3501a3501b350181501b1501e1501f150181001f15018300
011000001b15018150183501b3501e3501f3501830018300183501b3501e3501f35018300183001830018300183001b300183501b3501e3501f3501d3501b3501d3501e300183001f3001f300183001d30018300
01100000183001830017350183501a3501d3501535016350173501a3501735013350183001830018300183001e3001f300123501335014350153501635017350183501e300183001f30030800183001d30018300
010800200c655006050c6550c6050c6550060524655006050c655006050c6551860524655006050c655006050c655006050c6550c6550c6550060524655006050c655006050c6551860524655006050c65500605
0002000037335170353d33517035170352f635150353b3353d63512035373353433511035396352f3350e0352f635253352e6350c0351933529635123353063525635013353363527635286353b6351f63531635
011000000047500005004750000503475034050347500005024750247502405014700147501400014750140500475000050047500005034750000503475000050247502475000050147501405064700647006470
0008000b086540965409654076540665406654096540b6540c6540c6540c6540e6540e6540e6540e6540e6540e6540e6541065411654146541565416654166541565412654116541165411654116541165413654
010802203164519615206111f6111d6111c6111a6111a6111a6111e6111e6111e6111e6111f6111f6111f6111f6111f6111e6111b6111a611186111861118611186111861118611196111d6111f6112161121611
0104000024645247502b6452b75025505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600022b7232b7232b7032b7032b7032b7032b70315203150031d0031d0031d0031d0031d0031d0031d0031e0031e0031d0031c0031c0031e0031e0031e0031e0031e0031d0031d0031d0031d0031d0031d003
011000001830018300183501b3501e3501f3501830018300183501b3501f3501e3501e3521e3421e3321e32537805378001f3501e3501d3501d3501b3501b3501a3521a3521a3521835217342173421433214325
0110000030843308231a3501735014350133501235013350143501335514355173551a3551735217352173551a3501b3001835014300173501a350133001b3501b3001b100271421e1022a1422b1422b1422b142
011000001830018300183501b3001b3501f300183501b350203501b3501e3501f3501f2003084330833308233081330803183001b3001e3001f3001d3001b3001d3501d3501d3501b3501a3501a3501835018350
0110000017342183002f842113001a3421d30032842163001d3521a300358520e00020362183003886218300233701f300143401330013340173521735517305183751e800183001f30030800183001d30018300
011e00002f8223282235822398222f8223282235822398222f8223282235822398222f8223282235822398222f8223282235822398222f8223282235822398222f8223282235822398222f822328223582239822
011e000017130171311713117131171311713117131171311e1311e1311e1311e1311e1311e1311e1311e1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a1311a131
011e000017130171311713117131171311713117131171311e1311e1311e1311e1311e1311e1311e1311e1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f1311f131
011e00002f8223282235822398222f8223282235822398222f8223282235822398222f8223282235822398223082233822378223a8223082233822378223a8223082233822378223a8223082233822378223a822
011e00000b0700b0600b0500b0400b0300b0200b0150b000060700606006050060400603006020060150700007070070600705007040070300702007015070000700007000070000700007000070000700000000
011e00000b0700b0600b0500b0400b0300b0200b0150b00512070120601205012040120301202012015120051107011060110501104011030110201101506070050700506005050050400503005020050150a000
010f00000b1750b1750b1750b1750b1750b1750b1750b1750b1750b1750b1750b1750b1750b1750b1750b17506175061750617506175061750617506175061750617506175061750617506175061750617506175
010f00000c6250c625246450c6350c6250c625246450c6350c6250c625246450c6350c6250c625246450c6350c6250c625246450c6350c6250c625246450c6350c6250c625246450c6350c6250c625246450c635
010f00000717507175071750717507175071750717507175071750717507175071750717507175071750717507175071750717507175071750717507175071750717507175071750717507175071750717507175
011e000017232172321723217232172321723217232172321e2321e2321e2321e2321e2321e2321e2321e2321a1001a1001a1001a1001a1001a1001a1001a1001a1001a1001a1001a1001a1001a1001a1001a100
011e00001a2321a2321a2321a2321a2321a2321a2321a2321a2321a2321a2321a2321a2321a2321a2321a23200200000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001f2321f2321f2321f2321f2321f2321f2321f232202312023220232202322023220232162311623200202002000000000000000000000000000000000000000000000000000000000000000000000000
011e00000c6000c600246000c6000c6000c600246000c6000c6000c600246000c6000c6000c600246000c6000c6000c600246000c6000c6000c600246000c6000c6000c600246000c6000c635246450c63524645
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00003084330833308233081330803000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000100000f4450e4450d4450c4450b4550a4550945508455074650646505465044650347502475014750f0000e0000f4010f4050e4010e4010e4010e4050d4010d4010d4010d4050c4010c4010c4010c405
010400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000100001b4551a455194551843517435164351544514445134451245511455104550f4650e4650d46500000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 2d2c6e44
00 01421244
01 01021244
00 04031244
00 05071244
00 06081244
00 14071244
00 09081244
00 0c0a1244
00 0d0b1244
00 05191244
00 061a1244
00 141b1244
02 091c1244
00 211e521d
00 221f2920
01 2326241d
00 2527241d
00 2324261d
02 2524281d

