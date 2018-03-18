pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
music(0)

function _draw()
cls()
mapdraw()
drawskater(0,36)
drawskater(72,36)
drawskater(0,0)
drawskater(72,0)
  
end

function drawskater(x,y)
spr(1,x,y)
spr(2,x+8,y)
spr(17,x,y+8)
spr(18,x+8,y+8)
end

function _update()

end

__gfx__
00000000000000000000000000000000000000000000000066666666cccccccc0000000000000000000000000000000000000000000000000000000000000000
000000000000bbbbbbbbbb000000bbbbbbbbbb000000000066666666cccccccc0000000000000000000000000000000000000000000000000000000000000000
00700700000000333333aaa0000000333333aaa05555555565656565cccccccc0000000000000000000000000000000000000000000000000000000000000000
000770000000000991a1aaa00000000991a1aaa00000000055555555cccccccc0000000000000000000000000000000000000000000000000000000000000000
00077000000000009999999000000000999999900000000056565656cccccccc0000000000000000000000000000000000000000000000000000000000000000
00700700000000222220000000099922222000000000000055555555cccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000000099922e2e2299000000022e2e229905555555555555555cccccccc0000000000000000000000000000000000000000000000000000000000000000
0000000000000002eee2200000000002eee220000000000055555555cccccccc0000000000000000000000000000000000000000000000000000000000000000
00000000000000222e200000000000222e200000ccc00ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000222222000000000666666666000cc0cc0cc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000006666666660000006665500066600cc0cc0cc55555555555555550000000000000000000000000000000000000000000000000000000000000000
0000000000066655000566000064440000044408cc0cc0cc55555555555555550000000000000000000000000000000000000000000000000000000000000000
0000000000666500000566008888888888888880cc0cc0cc55555555555555550000000000000000000000000000000000000000000000000000000000000000
0000000006444000000444080070000000007000ccc00ccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888888888888800000000000000000cc0cc0cc55555555000000000000000000000000000000000000000000000000000000000000000000000000
000000000070000000007000000000000000000000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0707070707070707070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1515151515151507070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060606060607070707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616161616161615151515150707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050506060606060707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0505050505050516161616160606060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
