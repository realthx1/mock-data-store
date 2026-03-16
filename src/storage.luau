--!optimize 2

export type InternalGlobalConfig = {}

export type InternalDataVersion = {
	data: any?,
	creation_timestamp: number,
	update_timestamp: number,
	metadata: { [string]: any },
	user_ids: { number },
	version: number,
}

export type InternalDataEntry = {
	versions: { InternalDataVersion },
	key: string,
}

export type InternalDataStorage = {
	name: string,
	data: { [string]: InternalDataEntry },
	update_timestamp: number,
	creation_timestamp: number,
}

export type InternalOrderedDataStorage = {
	name: string,
	data: { [string]: number },
	update_timestamp: number,
	creation_timestamp: number,
}

export type InternalGlobalState = {
	data_stores: { [string]: InternalDataStorage },
	ordered_data_stores: { [string]: InternalOrderedDataStorage },
	global_data_store_name: string,
	config: InternalGlobalConfig,
}

local mod = {}

local function internal_data_version_new(
	data: any?,
	version: number,
	update_t: number,
	creation_t: number,
	user_ids: { number },
	metadata: { [string]: any }
): InternalDataVersion
	return {
		data = data,
		version = version,
		creation_timestamp = creation_t,
		update_timestamp = update_t,
		user_ids = user_ids,
		metadata = metadata,
	}
end

local function internal_data_entry_new(key: string): InternalDataEntry
	return {
		versions = {},
		key = key,
	}
end

local function internal_ordered_data_store_new(name: string, creation_time: number): InternalOrderedDataStorage
	return {
		name = name,
		data = {},
		creation_timestamp = creation_time,
		update_timestamp = creation_time,
	}
end

local function internal_data_store_new(name: string, creation_time: number): InternalDataStorage
	return {
		name = name,
		data = {},
		creation_timestamp = creation_time,
		update_timestamp = creation_time,
	}
end

local function internal_global_state_new(config: InternalGlobalConfig): InternalGlobalState
	return {
		data_stores = {},
		ordered_data_stores = {},
		global_data_store_name = "default_" .. math.random(12426, 56234121),
		config = config,
	}
end

mod.internal_data_version_new = internal_data_version_new
mod.internal_global_state_new = internal_global_state_new
mod.internal_data_store_new = internal_data_store_new
mod.internal_ordered_data_store_new = internal_ordered_data_store_new
mod.internal_data_entry_new = internal_data_entry_new

return mod
