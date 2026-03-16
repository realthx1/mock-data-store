--!optimize 2

local storage = require("./storage")
local utils = require("./utils")
local global_data_store = require("./GlobalDataStore")
local data_store_key_info = require("./DataStoreKeyInfo")
local data_store_key = require("./DataStoreKey")
local data_store_key_pages = require("./DataStoreKeyPages")
local data_store_version_pages = require("./DataStoreVersionPages")
local data_store_object_version_info = require("./DataStoreObjectVersionInfo")

--- https://create.roblox.com/docs/reference/engine/classes/DataStore
local mod = {}
local class_scope = setmetatable({}, { __index = global_data_store.class_scope })

export type RawMockDataStore = global_data_store.RawMockGlobalDataStore
export type MockDataStore = setmetatable<RawMockDataStore, typeof({ __index = class_scope })>

local function get_version_async(
	self: RawMockDataStore,
	key: string,
	version: string
): (any?, data_store_key_info.MockDataStoreKeyInfo?)
	utils.arg_assert(key, "string", 2)
	utils.arg_assert(version, "string", 3, true)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)

	local data_store = assert(
		self._global_state.data_stores[self._data_store_name],
		"Failed to retrieve data store '" .. self._data_store_name .. "'"
	)
	local entry = data_store.data[full_key]
	if not entry then return nil, nil end

	local ver_num = tonumber(version)
	if not ver_num then return nil, nil end
	for _, ver in entry.versions do
		if ver.version == ver_num then
			return ver.data,
				data_store_key_info.new(
					ver.version,
					ver.update_timestamp,
					ver.creation_timestamp,
					ver.user_ids,
					ver.metadata
				)
		end
	end

	return nil, nil
end

local function get_version_at_time_async(
	self: RawMockDataStore,
	key: string,
	timestamp: number
): (any?, data_store_key_info.MockDataStoreKeyInfo?)
	utils.arg_assert(key, "string", 2)
	utils.arg_assert(timestamp, "number", 3, true)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)

	local data_store = assert(
		self._global_state.data_stores[self._data_store_name],
		"Failed to retrieve data store '" .. self._data_store_name .. "'"
	)
	local entry = data_store.data[full_key]
	if not entry then return nil, nil end

	for _, ver in entry.versions do
		if ver.update_timestamp == timestamp then
			return ver.data,
				data_store_key_info.new(
					ver.version,
					ver.update_timestamp,
					ver.creation_timestamp,
					ver.user_ids,
					ver.metadata
				)
		end
	end

	return nil, nil
end

local function list_versions_async(
	self: RawMockDataStore,
	key: string,
	sort_dir: Enum.SortDirection?,
	min_time: number?,
	max_time: number?,
	pagesize: number?
): data_store_version_pages.MockDataStoreVersionPages
	pagesize = pagesize or 1024
	sort_dir = sort_dir or Enum.SortDirection.Ascending

	utils.arg_assert(key, "string", 2, true)
	utils.arg_assert(sort_dir, "SortDirection", 3, true)
	utils.arg_assert(min_time, "number", 4, true)
	utils.arg_assert(max_time, "number", 5, true)
	utils.arg_assert(pagesize, "number", 6, true)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)

	local data_store = assert(
		self._global_state.data_stores[self._data_store_name],
		"Failed to retrieve data store '" .. self._data_store_name .. "'"
	)

	local entry = data_store.data[full_key]
	if not entry or #entry.versions == 0 then return data_store_version_pages.new({}) end

	local vers = entry.versions

	local start_i: number = 1
	local end_i: number = #vers
	local start_found = false
	local end_found = false

	if min_time or max_time then
		for i, ver in vers do
			if not start_found and min_time and ver.update_timestamp >= min_time then
				start_i = i
				start_found = true
			end
			if max_time and ver.update_timestamp <= max_time then
				end_i = i
				end_found = true
			end
		end
		if not end_found then return data_store_version_pages.new({}) end
	end
	vers = table.move(vers, start_i, end_i, 1, {})

	if sort_dir and sort_dir == Enum.SortDirection.Descending then
		for i = 1, #vers // 2 do
			local swap_i = #vers - i + 1
			vers[i], vers[swap_i] = vers[swap_i], vers[i]
		end
	end

	local pages: { { data_store_object_version_info.MockDataStoreObjectVersionInfo } } = {}

	local pages_num = math.ceil(#vers / pagesize)

	for page_num = 1, pages_num do
		local page = {}
		for i = ((page_num - 1) * pagesize) + 1, math.min(page_num * pagesize, #vers) do
			local ver: storage.InternalDataVersion = vers[i]
			table.insert(
				page,
				data_store_object_version_info.new(tostring(ver.version), ver.update_timestamp, ver.data == nil)
			)
		end
		table.insert(pages, page)
	end

	return data_store_version_pages.new(pages)
end

local function list_keys_async(
	self: RawMockDataStore,
	prefix: string?,
	pagesize: number?,
	cursor: string?,
	exclude_deleted: boolean?
): data_store_key_pages.MockDataStoreKeyPages
	pagesize = pagesize or 50

	utils.arg_assert(prefix, "string", 2, true)
	utils.arg_assert(pagesize, "number", 3, true)
	utils.arg_assert(cursor, "string", 4, true)
	utils.arg_assert(exclude_deleted, "boolean", 5, true)

	local data_store = assert(
		self._global_state.data_stores[self._data_store_name],
		"Failed to retrieve data store '" .. self._data_store_name .. "'"
	)

	local data = data_store.data
	local keys: { string } = {}

	for key, ver in data do
		if prefix and key:sub(1, prefix:len()) ~= prefix then continue end
		if exclude_deleted and ver.versions[#ver.versions].data == nil then continue end
		table.insert(keys, key)
	end

	local pages: { { data_store_key.MockDataStoreKey } } = {}

	local pages_num = math.ceil(#keys / pagesize)
	local cursor_num = tonumber(cursor) or 1

	for page_num = 1, pages_num do
		local page = {}
		local empty = true
		for i = cursor_num + ((page_num - 1) * pagesize), math.min(cursor_num + page_num * pagesize - 1, #keys) do
			table.insert(page, data_store_key.new(keys[i]))
			empty = false
		end
		if empty then break end
		table.insert(pages, page)
	end

	return data_store_key_pages.new(pages, cursor_num)
end

local function new(global: storage.InternalGlobalState, name: string, all_scopes: boolean, scope: string?)
	local ins = global_data_store.new_raw(global, name, false, all_scopes, scope)
	return setmetatable(ins, { __index = class_scope })
end

class_scope.GetVersionAsync = get_version_async
class_scope.GetVersionAtTimeAsync = get_version_at_time_async
class_scope.ListVersionsAsync = list_versions_async
class_scope.ListKeysAsync = list_keys_async
class_scope.ClassName = "DataStore"

mod.new = new

return mod
