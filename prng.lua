--[[ 
 
 prng -- v0.5.0 public domain Lua pseudo random generator
 no warranty implied; use at your own risk

 author: Ilya Kolbin (iskolbin@gmail.com)
 url: github.com/iskolbin/prng

 This is Lua port of C-code by S.M.Prigarin (smp@osmf.sscc.ru) taken from
 http://osmf.sscc.ru/~smp/random26.zip. According to comments in original
 sources this PRNG has small period of 2^38.

 This library is developed to mimic Lua math.random function and produce
 same numbers on different versions of Lua running on different platform.
 It's not using bit or bit32 or Lua 5.3 bit operators.

 PERFORMANCE

 Naive testing shows that prng.random is 6-8x times slower than math.random
 on vanilla Lua and 1.5-2x times slower on LuaJIT.

 COMPATIBILITY

 Lua 5.1, 5.2, 5.3, LuaJIT 1, 2

 LICENSE

 This software is dual-licensed to the public domain and under the following
 license: you are granted a perpetual, irrevocable license to copy, modify,
 publish, and distribute this file as you see fit.

--]]

local prng = {}

local floor = math.floor

local a1, a2, a3 = 1, 0, 0

function prng.f64()
  local x1 = 1.0 / 4096.0
	local x2 = x1 / 16384.0
	local x3 = x2 / 16384.0
  local c11, c12, c13, c21, c22, c31 = 11973*a1, 11973*a2, 11973*a3, 2800*a1, 2800*a2, 2842*a1
  local d1 = c11
	local d2 = c21 + c12 + floor(d1 / 2^14)
	local d3 = c31 + c22 + c13 + floor(d2 / 2^14)
	a1, a2, a3 = d1 % 16384, d2 % 16384, d3 % 4096
  return a3*x1 + a2*x2 + a1*x3
end

function prng.randomseed( seed )
	a1 = seed % 16384
	if a1 % 2 == 0 then a1 = a1+1 end
	a2 = floor( seed / 16383 ) % 16384
	a3 = floor( seed / 268402689 ) % 4096
end

function prng.u32()
	return prng.f64() * 0xffffffff 
end

function prng.i32()
	return prng.f64() * 0xffffffff - 0x80000000
end

function prng.random( from, to )
	if from == nil and to == nil then
		return prng.f64()
	else
		if to == nil then
			from, to = 1, from
			if from > to then
				error( "bad argument #1 to 'random' (interval is empty)" )
			end
		end
		if from > to then
			error( "bad argument #1 to 'random' (interval is empty)" )
		end
		local interval = to - from + 1
		return from + floor( interval*prng.f64())
	end
end

return prng
