pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

-- constants
tpb=16 // ticks per beat
lst=16*tpb // loopstart tick
let=lst+176*tpb // loopend tick
early = 8 // early display ticks
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

  -- acceleration due to gravity
g = 0.6

-- end constants


-- global variables
t = nil
player = nil

-- end global variables


function make_player(x,y)
  local p = {}
  p.x = x
  p.y = y
  p.dy = 0
  p.ddy = g  -- acceleration due to gravity
  return p
end


function update_player(p)
  if (btn(keys.left)) then p.x -= 1 end
  if (btn(keys.right)) then p.x += 1 end

  -- vertical motion with simplistic gravity
  if (btn(keys.up) or btn(keys.a)) then
    p.dy = 0 -- reset falling from gravity
    p.y -= 1
  else
    apply_gravity(p)
  end 
  
  update_anim(p)
end

function update_anim(p)
		frm = flr(t/6)%7
		p.frame = 80+2*frm
		p.framew = 2
		p.frameh = 3
		p.yoffset = 0
		if (frm >=3 and frm <=5)
			then p.yoffset = -8
		end
end

function apply_gravity(p)
  if (p.y < 36) then
    p.dy += p.ddy
    p.y += p.dy
  else
    p.dy = 0 -- we are on the ground
  end
end


function drawskater(p)
  spr(p.frame,p.x,p.y+p.yoffset-24,p.framew,p.frameh)
end


function _init()
  player = make_player(0,36)
 
  -- title music
  music(13)

  palt(0,false)
  palt(7,true)
end

function drawscrollmap(s,mx,my,x,y,w,h)
		tx = flr(s/8)%w
  dx = -(s%8)
  mapdraw(mx+tx,my,dx,y,w-tx,h)
  mapdraw(mx,my,(w-tx)*8+dx,y,tx+1,h)
end		

function _draw()
  cls()
  --sky
  rectfill (0,0,127,127,12)
  --cloud
  palt(0,true)
  palt(7,false)
  spr(1,72,16,4,1)
  palt(0,false)
  palt(7,true)
  -- far far mountains
  mapdraw(32,1,0,4*8,32,3)
  
  if (t == nil) then
   local text =
    'press any key to start'
   print(
    text,
    8*8 - (#text*4)/2,
    8*7,
    7
   )
   return
  end
  
  s = t
  -- background
  drawscrollmap(s/8,32,5,0,5*8,16,2);
  drawscrollmap(s/4,32,7,0,7*8,16,2);
  drawscrollmap(s/2,32,9,0,9*8,16,5);
  -- foreground
  drawscrollmap(s,0,0,0,0,16,16)
  drawskater(player)
  --bump
  --spr(11,9*8,12*8,4,3)

 -- lyric cursor
  local lc =
    --(t-lst)%(let-lst) + early
    (t-lst)+early //verse 1 only

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
end

function any_btn()
  return (
   btn(0) or btn(1) or
   btn(2) or btn(3) or
   btn(4) or btn(5)
  )
end

timeout = nil
function _update60()
  if timeout == nil then
    if any_btn() then
     timeout = 40
     music(-1)
     sfx(42)
     -- wait 400 ms before
     -- starting game
    end
    return
  elseif timeout > 0 then
   timeout = timeout - 1
   if timeout == 0 then
    t = -1
    music(0)
   else
    return
   end
  end

  update_player(player)

  if (btn(4)) then
    // if z is pressed...
    sfx(19) // test explosion
  end
  if (btn(5)) then
    sfx(23)
  end
end

__gfx__
000000000000000000000000000000000000000070000000000000000000000700000007ffffffff000000007777777777777777777777777777777700000000
000000000000000777777777770000000000000005666666666666666666666066666660ffffffff000000007777777777777770077777777777777700000000
007007000000007777777777777000000000000001565656565656565656566056565660ffffffff00000000777777777777770ff07777777777777700000000
000770000000007777777777777000000000000001555555555555555555556055555560ffffffff0000000077777777777770ffff0777777777777700000000
000770000777777777777777777777000000000001555555555555555555556055555560ffffffff000000007777777777770ffffff077777777777700000000
0070070077777777777777777777777777777700015555555555555555555560555555604444444400000000777777777770ffffffff07777777777700000000
000000007777777777777777777777777777777001555555555555555555556055555560444444440000000077777777770ffffffffff0777777777700000000
00000000077777777777777777777777777777000155555555555555555555605555556044444444777777777777777770fffff44fffff077777777700000000
0000000000000000000000000000000000000000015555555555555555555560555555604444444400000000777777770fffff4444fffff07777777700000000
00000000000000000000000000000000000000000155555555555555555555605555556044444444ffffffff77777770fffff4ffff4fffff0777777700000000
00000000000000000000000000000000000000000155555555555555555555605555556044444444ffffffff7777770fffff44444444fffff077777700000000
00000000000000000000000000000000000000000155555555555555555555605555556044444444ffffffff777770fffff4ffffffff4fffff07777700000000
00000000000000000000000000000000000000000155555555555555555555605555556044444444ffffffff77770fffff4ffffffffff4fffff0777700000000
00000000000000000000000000000000000000000155555555555555555555605555556044444444444444447770fffff44444444444444fffff077700000000
0000000000000000000000000000000000000000015555555555555555555560555555604444444444444444770fffff4444444444444444fffff07700000000
000000000000000000000000000000000000000001555555555555555555556055555560444444444444444470fffff444444444444444444fffff0700000000
00000000000000000000000000000000000000000155555555555555555555605555556077777700000777770fffff44444444444444444444fffff000000000
0000000000000000000000000000000000000000015555555555555555555560555555607777708888807777fffff4444444444444444444444fffff00000000
0000000000000000000000000000000000000000015555555555555555555560555555607777708880007777ffff444444444444444444444444ffff00000000
0000000000000000000000000000000000000000015555555555555555555560555555607777708804407777fff44444444444444444444444444fff00000000
0000000000000000000000000000000000000000015555555555555555555560555555607777770809907777ff4444444444444444444444444444ff00000000
00000000000000000000000000000000000000000155555555555555555555605555556077000008000000074444444444444444444444444444444400000000
00000000000000000000000000000000000000000155555555555555555555605555556070994888888844904444444444444444444444444444444400000000
00000000000000000000000000000000000000000566666666666666666666606666666077000088880000074444444444444444444444444444444400000000
00000000000000000000000000000000000000000155555555555555555555605555556077777088880777770000000000000000000000000000000000000000
00000000000000000000000000000000000000000155555555555555555555605555556077770088880007770000000000000000000000000000000000000000
00000000000000000000000000000000000000000155555555555555555555605555556077706666666660770000000000000000000000000000000000000000
00000000000000000000000000000000000000000566666666666666666666606666666077066dd0000d66070000000000000000000000000000000000000000
0000000000000000000000000000000000000000015555555555555555555560555555607066d007770d66070000000000000000000000000000000000000000
00000000000000000000000000000000000000000566666666666666666666606666666000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000566666666666666666666606666666008888888888888800000000000000000000000000000000000000000
00000000000000000000000000000000000000000555555555555555555555506666666070a000000000a0070000000000000000000000000000000000000000
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777700077777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777049907777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777770000040077777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777708888807777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777708888807777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777708800007777777777000007777777777770000077777777777700000777777777777777777777777777777777777
77777700000777777777777777777777777708044407777777770888880000777777708888807777777777088888077777777777777777777777777777777777
77777088888077777777777777777777777708099077777777770888880499077777708888807777770077088888077777777777777777777777777777777777
77777088800077777777770000077777700008800077777777770880000000777777708800007777709900088000077777777700000777777777777777777777
77777088044077777777708888807777099488888077777777770804440777777777708044400000770448880444077777777088888077777777777777777777
77777708099077777777708880007777090008888077777777770809907777770000008099088990777000080990777777777088800077777777777777777777
77777708099077777777708804407777090708888000777777000880007777770994888800000007777777088000077777777088044077777777777777777777
7700000880000007777777080990777770770888d666077770448888807777777000008888077777777777088888800777777708099077777777777777777777
709948888888449077000008099000077777088d00d6000709900888807777777777708888077777777777088880099077000008099000077777777777777777
77000088880000077099488880084490777708d070d6080700070888800007777777708888007777777000088880700770994888800844907777777777777777
7777708888077777770000888800000777770d6070d0807777770dddddd6607777770ddddd660777770666ddddd0777777000088880000077777777777777777
777770888800777777777088880777777777066070080077777066d000dd6007777066d000d660777006dd000d66077777777088880777777777777777777777
77770ddddd6607777777008888000777777706607080a077777066077700088077066d07770d66070880007770d6077777770088880007777777777777777777
777066d000d66077777066ddddd66077777706600807077777706607700880077066d077770d66077008800770d66077777066ddddd660777777777777777777
77066d07770d660777066dd0000d660777770660807777777706607008800a07000000000000000070a00880070d607777066dd0000d66077777777777777777
7066d077770d66077066d007770d660777770608077777777706600880077077088888888888888077077008800d60777066d007770d66077777777777777777
000000000000000000000000000000007777008077777777770008800777777770a000000000a007777777700880007700000000000000007777777777777777
08888888888888800888888888888880777088007777777777088007777777777777777777777777777777777008807708888888888888807777777777777777
70a000000000a00770a000000000a007777700a0777777777770a07777777777777777777777777777777777770a077770a000000000a0077777777777777777
33333333333333330000000077777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
33333333333333330000000077777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
33333333333333330000000077777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
33333333333333330000000077777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
333f3333333333330000000077777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
333333f3333333330000000077777777777333337777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
3f333f33333333330000000077777773333333333337777777777777777777777777777777777777777777770000000000000000000000000000000000000000
333f3333333333330000000077773333333333333333377777777777777777777777777777777777777777770000000000000000000000000000000000000000
f3ff333fffffffff0000000033333333333333333333333777777777777777777777777733333333333377770000000000000000000000000000000000000000
3f33f3ffffffffff0000000033333333333333333333333337777777777777777777333333333333333333330000000000000000000000000000000000000000
f3f33f33ffffffff0000000033333333333333333333333333377777777777777333333333333333333333330000000000000000000000000000000000000000
3333f333ffffffff0000000033333333333333333333333333333777777777333333333333333333333333330000000000000000000000000000000000000000
3f3f3f33ffffffff0000000033333333333333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
f3f333ffffffffff0000000033333333333333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
33333f3fffffffff0000000033333333333333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
333f333fffffffff0000000033333333333333333333333333333333333333333333333333333333333333330000000000000000000000000000000000000000
ffff3f3fffffffff4444444477777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
fff3f333ffffffff4444444477777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
ff3333f3ff3f3fff4444444477777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
f3f3333ff3f333ff4444444477777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
3f333fffff333f3f4444444477777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
f333f3fff3f333ff4444444477777777777777777777777777777777777777777777777777777777777777770000000000000000000000000000000000000000
3f333ffff33d333f44444444777777777777777777777777777777777777777777777777dddd7777777777770000000000000000000000000000000000000000
33d333ffffffffff4444444477777777777777777ddddddd7777777777777777777777dddddddd77777777770000000000000000000000000000000000000000
ff3ff3ffff3f3f3fdddddddd77777777dddd77ddddddddddddd777777777777dddddddddddddddd7777777770000000000000000000000000000000000000000
3ff3333ff3f333f3dddddddd7777777ddddddddddddddddddddddddd77777ddddddddddddddddddd777777770000000000000000000000000000000000000000
f33f33f33f33f33fdddddddd77777dddddddddddddddddddddddddddddddddddddddddddddddddddd77777770000000000000000000000000000000000000000
3f33f33ff3f33d33dddddddd77dddddddddddddddddddddddddddddddddddddddddddddddddddddddddd77770000000000000000000000000000000000000000
333f3d33333f33f3dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000
3f3333f3f33d333fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000
f33d333f3ff3df3fdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000
3ffddff3ffffffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000a3a4a5a6a7a8a9aaa3a4a5a6a7a8a9aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b3b4b5b6b7b8b9bab3b4b5b6b7b8b9ba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000b2b2b2b2b2b2b2b2b2b2b2b2b2b2b2b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0506060606060700000000000000000000000000000000000000000000000000838485868788898a838485868788898a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161616161700000000000000000000000000000000000000000000000000939495969798999a939495969798999a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161616161705060606070000000000000000000000000000000000000000808080808080808080808080808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161616161715161616170000000000000000000000000000000000000000909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161616161715161616170000000000000000000000000000000000000000a0a1a0a1a0a1a0a1a0a1a0a1a0a1a0a10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161616161715161616170000000000000000000000000000000000000000b0b091b1b0b091b1b0b091b1b0b091b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516161616161715161616170000000000000000000000000000000000000000b091b091b091b091b091b091b091b0910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2526262626262725262626270000000000000000000000000000000000000000919191919191919191919191919191910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3536363636363735363636370000000000000000000000000000000000000000919191919191919191919191919191910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1919191919191919191919191919191900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
010802203165031655206211f6211d6211c6211a6211a6211a6211e6211e6211e6211e6211f6211f6211f6211f6211f6211e6211b6211a621186211862118621186211862118621196211d6211f6212162121621
0104000024655247502b6552b75025505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01080000290552f05536000360003600036000360003600018700177051f702247021f702167051e7021e702187001e7001e700137001e7001d7001d700127001d7001c7001c7001b7001b7001b7001b7001c700
__music__
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

