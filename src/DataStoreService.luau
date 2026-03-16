--!optimize 2

local storage = require("./storage")
local utils = require("./utils")
local instance = require("./Instance")
local data_store = require("./DataStore")
local ordered_data_store = require("./OrderedDataStore")
local data_store_listing_pages = require("./DataStoreListingPages")
local data_store_info = require("./DataStoreInfo")

--- https://create.roblox.com/docs/reference/engine/classes/DataStoreService
local mod = {}
local class_scope = setmetatable({}, { __index = instance.class_scope })

export type RawMockDataStoreService = {
	_global_state: storage.InternalGlobalState,
}
export type MockDataStoreService = setmetatable<RawMockDataStoreService, typeof({ __index = class_scope })>

local function get_data_store(
	self: RawMockDataStoreService,
	name: string,
	scope: string?,
	options: DataStoreOptions?
): data_store.MockDataStore
	utils.arg_assert(name, "string", 2)
	utils.arg_assert(scope, "string", 3, true)
	utils.arg_assert(options, "DataStoreOptions", 4, true)

	local data_store_obj = self._global_state.data_stores[name]
	if not data_store_obj then
		data_store_obj = storage.internal_data_store_new(name, utils.current_time())
		self._global_state.data_stores[name] = data_store_obj
	end

	return data_store.new(self._global_state, name, if options then options.AllScopes else false, scope)
end

local function get_global_data_store(self: RawMockDataStoreService): data_store.MockDataStore
	local data_store_obj = self._global_state.data_stores[self._global_state.global_data_store_name]
	if not data_store_obj then
		data_store_obj =
			storage.internal_data_store_new(self._global_state.global_data_store_name, utils.current_time())
		self._global_state.data_stores[self._global_state.global_data_store_name] = data_store_obj
	end

	return data_store.new(self._global_state, self._global_state.global_data_store_name, false, "u")
end

local function get_ordered_data_store(
	self: RawMockDataStoreService,
	name: string,
	scope: string?
): ordered_data_store.MockOrderedDataStore
	utils.arg_assert(name, "string", 2)
	utils.arg_assert(scope, "string", 3, true)

	local data_store_obj = self._global_state.ordered_data_stores[name]
	if not data_store_obj then
		data_store_obj = storage.internal_ordered_data_store_new(name, utils.current_time())
		self._global_state.ordered_data_stores[name] = data_store_obj
	end

	return ordered_data_store.new(self._global_state, name, scope)
end

local function list_data_stores_async(
	self: RawMockDataStoreService,
	prefix: string?,
	pagesize: number?,
	cursor: string?
): data_store_listing_pages.MockDataStoreListingPages
	pagesize = pagesize or 32

	utils.arg_assert(prefix, "string", 2, true)
	utils.arg_assert(pagesize, "number", 3, true)
	utils.arg_assert(cursor, "string", 4, true)

	local data_stores = self._global_state.data_stores
	local keys: { string } = {}

	for key, data_store_obj in data_stores do
		if prefix and key:sub(1, prefix:len()) ~= prefix then continue end
		local empty = true
		for _ in data_store_obj.data do
			empty = false
			break
		end
		if empty then continue end
		table.insert(keys, key)
	end

	local pages: { { data_store_info.MockDataStoreInfo } } = {}

	local pages_num = math.ceil(#keys / pagesize)
	local cursor_num = tonumber(cursor) or 1

	for page_num = 1, pages_num do
		local page = {}
		for i = cursor_num + ((page_num - 1) * pagesize), math.min(cursor_num + page_num * pagesize - 1, #keys) do
			local data_store = data_stores[keys[i]]
			table.insert(page, data_store_info.new(keys[i], data_store.update_timestamp, data_store.update_timestamp))
		end
		table.insert(pages, page)
	end

	return data_store_listing_pages.new(pages, cursor_num)
end

local function new(global: storage.InternalGlobalState): MockDataStoreService
	return setmetatable({ _global_state = global }, { __index = class_scope })
end

class_scope.GetDataStore = get_data_store
class_scope.GetOrderedDataStore = get_ordered_data_store
class_scope.GetGlobalDataStore = get_global_data_store
class_scope.ListDataStoresAsync = list_data_stores_async
class_scope.ClassName = "DataStoreService"

mod.new = new

return mod
