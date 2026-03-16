--!optimize 2

local mod = {}

local function full_key(scope: string?, key: string, no_append: boolean?): string
	if no_append then return key end
	return (scope or "global") .. "/" .. key
end

local function current_time(): number
	return (os.time() + (os.clock() % 1)) * 1000 // 1
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
	assert(t == exp_t, "Bad argument #" .. arg_n .. ", " .. exp_t .. (optional and "?" or "") .. "expected, got " .. t)
	return arg
end

mod.arg_assert = arg_assert
mod.full_key = full_key
mod.current_time = current_time

return mod
