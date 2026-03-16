-- dont at this atrocity pls

local mock = require(script.mock_data_store)

local DataStoreService = mock.new()

local data_store = DataStoreService:GetDataStore("ez", "")

do
	data_store:SetAsync("ex", 2)
	local res, res2 = data_store:GetAsync("ex")
	assert(res == 2 and res2 and res2.Version == "1")
end

do
	assert(data_store:SetAsync("ex", 3) == "2")
	local res, res2 = data_store:GetAsync("ex")
	assert(res == 3 and res2 and res2.Version == "2")
end

do
	assert(data_store:IncrementAsync("ex", 3) == "3")
	local res, res2 = data_store:GetAsync("ex")
	assert(res == 6 and res2 and res2.Version == "3")
end

do
	data_store:UpdateAsync("ex", function(data)
		assert(data == 6)
		return 0
	end)
	local res, res2 = data_store:GetAsync("ex")
	assert(res == 0 and res2 and res2.Version == "4")
end

do
	assert(data_store:UpdateAsync("ex", function(data)
		assert(data == 0)
		return nil
	end) == nil)
	local res, res2 = data_store:GetAsync("ex")
	assert(res == 0 and res2 and res2.Version == "4")
end

do
	data_store:RemoveAsync("ex")
	local res, res2 = data_store:GetAsync("ex")
	assert(res == nil and res2 == nil)
end

do
	data_store:SetAsync("ex", 10)
	task.wait(0.1)
	data_store:SetAsync("ex", nil)
	local res, res2 = data_store:GetAsync("ex")
	assert(res == nil and res2 == nil)
end

do
	local res, res2 = data_store:GetVersionAsync("ex", "7")
	assert(res == nil and res2 and res2.Version == "7")
	local res3, res4 = data_store:GetVersionAtTimeAsync("ex", res2.UpdatedTime)
	assert(res3 == nil and res4 and res4.Version == "7")
end

do
	local res, res2 = data_store:GetVersionAsync("ex", "8")
	assert(res == nil and res2 == nil)
end

do
	print(data_store:ListVersionsAsync("ex", Enum.SortDirection.Descending, nil, nil, 4))
end

do
	data_store:SetAsync("ef", 1)
	data_store:SetAsync("eu", 1)
	data_store:SetAsync("eh", 1)
	print(data_store:ListKeysAsync(nil, 2, "2", true))
end

local ordered_data_store = DataStoreService:GetOrderedDataStore("example")

do
	ordered_data_store:SetAsync("ex", 2)
	local res, res2 = ordered_data_store:GetAsync("ex")
	assert(res == 2 and res2 == nil)
end

do
	ordered_data_store:SetAsync("ex", 3)
	local res, res2 = ordered_data_store:GetAsync("ex")
	assert(res == 3 and res2 == nil)
end

do
	ordered_data_store:UpdateAsync("ex", function(data)
		assert(data == 3)
		return 0
	end)
	local res, res2 = ordered_data_store:GetAsync("ex")
	assert(res == 0 and res2 == nil)
end

do
	assert(ordered_data_store:UpdateAsync("ex", function(data)
		assert(data == 0)
		return nil
	end) == nil)
	local res, res2 = ordered_data_store:GetAsync("ex")
	assert(res == 0 and res2 == nil)
end

do
	ordered_data_store:RemoveAsync("ex")
	local res, res2 = ordered_data_store:GetAsync("ex")
	assert(res == nil and res2 == nil)
end

do
	ordered_data_store:SetAsync("is", -1)
	ordered_data_store:SetAsync("fs", 1)
	ordered_data_store:SetAsync("1s", 1)
	ordered_data_store:SetAsync("es", 10)
	ordered_data_store:SetAsync("ts", 11)
	print(ordered_data_store:GetSortedAsync(2, 0, 10))
end

do
	DataStoreService:GetDataStore("a"):SetAsync("a", 1)
	DataStoreService:GetDataStore("aa"):SetAsync("a", 1)
	DataStoreService:GetDataStore("aaa"):SetAsync("a", 1)
	DataStoreService:GetDataStore("aaaa"):SetAsync("a", 1)
	DataStoreService:GetDataStore("aaaaa"):SetAsync("a", 1)
	print(DataStoreService:ListDataStoresAsync("aaa", 2))
end

print("passed")
