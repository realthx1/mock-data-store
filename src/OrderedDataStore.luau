--!optimize 2
-- https://create.roblox.com/docs/reference/engine/classes/OrderedDataStore

local storage = require("./storage")
local utils = require("./utils")
local global_data_store = require("./GlobalDataStore")
local data_store_pages = require("./DataStorePages")

local mod = {}
local class_scope = setmetatable({}, { __index = global_data_store.class_scope })

export type RawMockOrderedDataStore = global_data_store.RawMockGlobalDataStore
export type MockOrderedDataStore = setmetatable<RawMockOrderedDataStore, typeof({ __index = class_scope })>

local function get_sorted_async(
	self: MockOrderedDataStore,
	pagesize: number?,
	min_value: number?,
	max_value: number?
): data_store_pages.MockDataStorePages
	pagesize = utils.str_to_num(pagesize)
	min_value = utils.str_to_num(min_value)
	max_value = utils.str_to_num(max_value)
	pagesize = pagesize or 50

	utils.arg_assert(pagesize, "number", 2)
	utils.arg_assert(pagesize, "number", 3, true)
	utils.arg_assert(pagesize, "number", 4, true)

	assert(math.clamp(pagesize, 1, 100), "pagesize is too small or large")

	local data_store = assert(
		self._global_state.ordered_data_stores[self._data_store_name],
		"Failed to retrieve data store '" .. self._data_store_name .. "'"
	)

	local data_mass = data_store.data

	local ordered_keys: { string } = {}
	for k in data_mass do
		table.insert(ordered_keys, k)
	end
	table.sort(ordered_keys, function(k1: string, k2: string)
		if data_mass[k1] > data_mass[k2] then return true end
		return false
	end)

	local start_i: number = 1
	local end_i: number = #ordered_keys

	if min_value then
		for i = #ordered_keys, 1, -1 do
			local key = ordered_keys[i]
			local val = data_mass[key]
			if val >= min_value then
				end_i = i
				break
			end
		end
	end
	if max_value then
		for i = 1, #ordered_keys do
			local key = ordered_keys[i]
			local val = data_mass[key]
			if val <= max_value then
				start_i = i
				break
			end
		end
	end

	ordered_keys = table.move(ordered_keys, start_i, end_i, 1, {})

	local pages = {}

	local pages_num = math.ceil(#ordered_keys / pagesize)

	for page_num = 1, pages_num do
		local page = {}
		for i = ((page_num - 1) * pagesize) + 1, math.min(page_num * pagesize, #ordered_keys) do
			local key = ordered_keys[i]
			local val = data_mass[key]
			table.insert(page, { key = key, value = val })
		end
		table.insert(pages, page)
	end

	return data_store_pages.new(pages)
end

local function new(global: storage.InternalGlobalState, name: string, scope: string?)
	local ins = global_data_store.new_raw(global, name, true, false, scope)
	return setmetatable(ins, { __index = class_scope })
end

class_scope.GetSortedAsync = get_sorted_async
class_scope.ClassName = "OrderedDataStore"

mod.new = new

return mod
