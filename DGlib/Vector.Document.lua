---@meta Vector_Quaternion

----------------------------------------

---@class DGlib.Vector # Vector & Quaternion, Immutable
---@field x number # vector[1]
---@field y number # vector[2]
---@field z number # vector[3]
---@field w number # vector[4]
---@field unit DGlib.Vector # Normalize (w >= 0, length = 1)
---@field length number # Module of vector
---@field lensqr number # Square module
---@field T DGlib.Vector # Quaternion conjugate
local vector4d = {}

---Create vector by numbers
---@param x number? # default = 0
---@param y number? # default = 0
---@param z number? # default = 0
---@param w number? # default = 0
---@return DGlib.Vector
function DG.Vector(x, y, z, w) end

---Create vector by number array or vector
---@param array number[] # array or vector
---@return DGlib.Vector
function DG.Vector(array) end

---Create quaternion by axis and angle
---@param axis number[]
---@param angle number
---@return DGlib.Vector
function DG.Vector(axis, angle) end

----------------------------------------

---2D rotation
---@param angle number
---@return DGlib.Vector
function vector4d:rotate(angle) end

---3D rotation by axis and angle
---@param axis number[]
---@param angle number
---@return DGlib.Vector
function vector4d:rotate(axis, angle) end

---3D rotation by quaternion
---@param quat DGlib.Vector # Quaternion for rotation
---@return DGlib.Vector
function vector4d:rotate(quat) end

----------------------------------------

---@class DGlib.Vector Belows are operations supported by vector
---| -vector -> vector # Oposite
---| vector + vector -> vector # Add
---| vector - vector -> vector # Minus
---| vector * number -> vector # Multiplied by number
---| number * vector -> vector # Multiplied by number
---| vector ^ vector -> number # Dot product
---| vector % vector -> vector # Cross product (3D)
---| vector / vector -> number # Cross product (2D)
---| vector * vector -> vector # Quaternion Multiply

---Print vector
function vector4d:print() end

---Get opposite vector
---@return DGlib.Vector
function vector4d:unm() end

---Add a vector
---@param other DGlib.Vector
---@return DGlib.Vector
function vector4d:add(other) end

---Minus a vector
---@param other DGlib.Vector
---@return DGlib.Vector
function vector4d:sub(other) end

---Multiplied by a number
---@param other number
---@return DGlib.Vector
function vector4d:mul(other) end

---Dot product
---@param other DGlib.Vector
---@return number
function vector4d:dot(other) end

---Cross product 2D
---@param other DGlib.Vector
---@return number
function vector4d:cross2d(other) end

---Cross product 3D
---@param other DGlib.Vector
---@return DGlib.Vector
function vector4d:cross3d(other) end

----------------------------------------

---@class DGlib.Convert
DG.Convert = {}

---Convert quaternion to vector base
---@param quat DGlib.Vector
---@return DGlib.Vector[] base
function DG.Convert.QuatToBase(quat) end

---Convert vector base to quaternion
---@param base DGlib.Vector[]
---@return DGlib.Vector quat
function DG.Convert.BaseToQuat(base) end

----------------------------------------

---@class DGlib.Vector
---@operator unm: DGlib.Vector
---@operator add: DGlib.Vector
---@operator sub: DGlib.Vector
---@operator mul: DGlib.Vector
---@operator div: number
---@operator pow: number
---@operator mod: DGlib.Vector
