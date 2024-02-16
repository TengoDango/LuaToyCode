---@meta lstg.Color

---@class lstg.Color
local f2dcolor = {
	---alpha channel [[0~255]]
	a = 0,
	---red channel [[0~255]]
	r = 0,
	---green channel [[0~255]]
	g = 0,
	---blue channel [[0~255]]
	b = 0,
	---32bit color [[0x00000000~0xFFFFFFFF]]
	argb = 0,
	--[==[
	---hue [[0~360]]
	h = 0.0,
	---saturation [[0~100]]
	s = 0.0,
	---value [[0~100]]
	v = 0.0,
	--]==]
}

---setter & getter
---@overload fun(self, argb:number)
---@overload fun(self, a:number, r:number, g:number, b:number)
---@return number a, number r, number g, number b
function f2dcolor:ARGB()
end

---构造颜色对象
---@overload fun(argb:number):lstg.Color
---@overload fun(a:number, r:number, g:number, b:number):lstg.Color
---@return lstg.Color
function Color(a, r, g, b)
end
