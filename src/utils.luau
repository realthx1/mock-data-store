--!optimize 2

local mod = {}

local function full_key(scope: string?, key: string, no_append: boolean?): string
	if no_append then return key end
	return (scope or "global") .. "/" .. key
end

local function current_time(): number
	return (os.time() + (os.clock() % 1)) * 1000 // 1
end

local function num_to_str(obj: unknown): string
	local t = typeof(obj)
	if t == "number" then return tostring(obj) end
	return obj :: string
end

local function str_to_num(obj: unknown): number
	local t = typeof(obj)
	if t == "string" then return tonumber(obj) :: number end
	return obj :: number
end

local function full_typeof(obj: any): string
	local t = typeof(obj)
	if t == "Instance" then return (obj :: Instance).ClassName end
	if t == "EnumItem" then return tostring((obj :: EnumItem).EnumType) end
	return t
end

local function arg_assert<T>(arg: T, exp_t: string, arg_n: number, optional: boolean?): T
	local t = full_typeof(arg)
	if optional and arg == nil then return arg end
	if typeof(arg) == "Instance" and exp_t == "Instance" then return arg end
	if typeof(arg) == "EnumItem" and exp_t == "EnumItem" then return arg end
	assert(t == exp_t, "Bad argument #" .. arg_n .. ", " .. exp_t .. (optional and "?" or "") .. " expected, got " .. t)
	return arg
end

mod.str_to_num = str_to_num
mod.arg_assert = arg_assert
mod.num_to_str = num_to_str
mod.full_key = full_key
mod.current_time = current_time

return mod
