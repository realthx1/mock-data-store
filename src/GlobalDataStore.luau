--!optimize 2

local storage = require("./storage")
local data_store_key_info = require("./DataStoreKeyInfo")
local utils = require("./utils")
local instance = require("./Instance")

--- https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore
local mod = {}
local class_scope = setmetatable({}, { __index = instance.class_scope })

export type RawMockGlobalDataStore = {
	_global_state: storage.InternalGlobalState,
	_data_store_name: string,
	_scope: string?,
	_all_scopes: boolean,
	_ordered: boolean,
}

export type MockGlobalDataStore = setmetatable<RawMockGlobalDataStore, { __index: typeof(class_scope) }>

local function remove_async(
	self: RawMockGlobalDataStore,
	key: string
): (any?, data_store_key_info.MockDataStoreKeyInfo?)
	utils.arg_assert(key, "string", 2)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)
	local cur_t = utils.current_time()

	if self._ordered then
		local data_store = assert(
			self._global_state.ordered_data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]
		if not entry then return nil, nil end

		data_store.data[full_key] = nil
		return nil, nil
	else
		local data_store = assert(
			self._global_state.data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]
		if not entry then return nil, nil end

		local prev_ver = entry.versions[#entry.versions]

		if not prev_ver or prev_ver.data == nil then return nil, nil end

		local ver = storage.internal_data_version_new(
			nil,
			prev_ver.version + 1,
			cur_t,
			prev_ver.creation_timestamp,
			{},
			{}
		)
		table.insert(entry.versions, ver)

		data_store.update_timestamp = cur_t
		return prev_ver.data,
			data_store_key_info.new(
				prev_ver.version,
				prev_ver.update_timestamp,
				prev_ver.creation_timestamp,
				ver.user_ids,
				ver.metadata
			)
	end
end

local function set_async(
	self: RawMockGlobalDataStore,
	key: string,
	value: any?,
	user_ids: { number }?,
	options: DataStoreSetOptions?
): string?
	utils.arg_assert(key, "string", 2)
	utils.arg_assert(user_ids, "string", 4, true)
	utils.arg_assert(options, "DataStoreSetOptions", 5, true)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)
	local cur_t = utils.current_time()

	if self._ordered then
		local data_store = assert(
			self._global_state.ordered_data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)

		data_store.data[full_key] = value

		return nil
	else
		local data_store = assert(
			self._global_state.data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]
		if not entry then
			local new_entry = storage.internal_data_entry_new(full_key)
			data_store.data[full_key] = new_entry
			entry = new_entry
		end

		local prev_ver = entry.versions[#entry.versions]

		local ver = storage.internal_data_version_new(
			value,
			if prev_ver then prev_ver.version + 1 else 1,
			cur_t,
			if prev_ver and prev_ver.data then prev_ver.creation_timestamp else cur_t,
			user_ids or {},
			if options then options:GetMetadata() else {}
		)
		table.insert(entry.versions, ver)

		data_store.update_timestamp = cur_t
		return tostring(ver.version)
	end
end

local function get_async(
	self: RawMockGlobalDataStore,
	key: string,
	options: DataStoreGetOptions?
): (any?, data_store_key_info.MockDataStoreKeyInfo?)
	utils.arg_assert(key, "string", 2)
	utils.arg_assert(options, "DataStoreGetOptions", 3, true)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)

	if self._ordered then
		local data_store = assert(
			self._global_state.ordered_data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]
		return entry, nil
	else
		local data_store = assert(
			self._global_state.data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]

		local ver = entry.versions[#entry.versions]
		if not ver or ver.data == nil then return nil, nil end

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

local function update_async(
	self: RawMockGlobalDataStore,
	key: string,
	transform: (
		any?,
		data_store_key_info.MockDataStoreKeyInfo?
	) -> (any?, { number }?, { [string]: any }?)
): (any?, data_store_key_info.MockDataStoreKeyInfo?)
	utils.arg_assert(key, "string", 2)
	utils.arg_assert(transform, "function", 3)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)
	local cur_t = utils.current_time()

	if self._ordered then
		local data_store = assert(
			self._global_state.ordered_data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]

		local res, _, _ = transform(entry)
		if res == nil then return nil, nil end
		data_store.data[full_key] = res

		data_store.update_timestamp = cur_t
		return res, nil
	else
		local data_store = assert(
			self._global_state.data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)
		local entry = data_store.data[full_key]

		local prev_ver = entry.versions[#entry.versions]

		local res, user_ids, metadata = transform(
			prev_ver.data,
			prev_ver
				and data_store_key_info.new(
					prev_ver.version,
					prev_ver.update_timestamp,
					prev_ver.creation_timestamp,
					prev_ver.user_ids,
					prev_ver.metadata
				)
		)

		if res == nil then return nil, nil end

		local ver = storage.internal_data_version_new(
			res,
			if prev_ver then prev_ver.version + 1 else 1,
			cur_t,
			if prev_ver and prev_ver.data then prev_ver.creation_timestamp else cur_t,
			user_ids or {},
			metadata or {}
		)
		table.insert(entry.versions, ver)

		data_store.update_timestamp = cur_t
		return tostring(ver.version),
			data_store_key_info.new(
				ver.version,
				ver.update_timestamp,
				ver.creation_timestamp,
				ver.user_ids,
				ver.metadata
			)
	end
end

local function increment_async(
	self: RawMockGlobalDataStore,
	key: string,
	delta: number,
	user_ids: { number }?,
	options: DataStoreIncrementOptions?
): string?
	utils.arg_assert(key, "string", 2)
	utils.arg_assert(delta, "number", 3)
	utils.arg_assert(user_ids, "table", 4, true)
	utils.arg_assert(options, "DataStoreIncrementOptions", 5, true)

	local full_key = utils.full_key(self._scope, key, self._all_scopes)
	local cur_t = utils.current_time()

	if self._ordered then
		local data_store = assert(
			self._global_state.ordered_data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)

		local entry = data_store.data[full_key]
		assert(entry, "Key '" .. key .. "' doesn't exist in data store '" .. self._data_store_name .. "'")

		data_store.data[full_key] = entry + delta

		data_store.update_timestamp = cur_t
		return nil
	else
		local data_store = assert(
			self._global_state.data_stores[self._data_store_name],
			"Failed to retrieve data store '" .. self._data_store_name .. "'"
		)

		local entry = data_store.data[full_key]
		assert(entry, "Key '" .. key .. "' doesn't exist in data store '" .. self._data_store_name .. "'")

		local prev_ver = entry.versions[#entry.versions]
		assert(typeof(prev_ver.data) == "number", "Data of key '" .. key .. "' is not an integer")

		local ver = storage.internal_data_version_new(
			prev_ver.data + delta,
			if prev_ver then prev_ver.version + 1 else 1,
			cur_t,
			if prev_ver then prev_ver.creation_timestamp else cur_t,
			user_ids or {},
			if options then options:GetMetadata() else {}
		)
		table.insert(entry.versions, ver)

		data_store.update_timestamp = cur_t
		return tostring(ver.version)
	end
end

local function new_raw(
	global: storage.InternalGlobalState,
	name: string,
	ordered: boolean,
	all_scopes: boolean,
	scope: string?
): RawMockGlobalDataStore
	return {
		_global_state = global,
		_data_store_name = name,
		_scope = scope,
		_all_scopes = all_scopes == true,
		_ordered = ordered,
	}
end

class_scope.RemoveAsync = remove_async
class_scope.GetAsync = get_async
class_scope.SetAsync = set_async
class_scope.UpdateAsync = update_async
class_scope.IncrementAsync = increment_async
class_scope.ClassName = "GlobalDataStore"

mod.class_scope = class_scope
mod.new_raw = new_raw

return mod
