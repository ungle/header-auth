--
--
-- User: ungle
-- Date: 2022/12/17
-- Time: 12:00
--
--
local constants = require "kong.constants"
local error = error
local HeaderAuthHandler = {
    PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
    VERSION = "0.1.0",
}

local function find_consumer(header)
    local consumer_cache_key = kong.db.consumers:cache_key(header)
    local consumer, err = kong.cache:get(consumer_cache_key, nil,
        kong.client.load_consumer,
        header,true)
    if err then
        return nil, err
    end
    return consumer,nil
end



local function set_consumer(consumer, credential)
    kong.client.authenticate(consumer, credential)
    local set_header = kong.service.request.set_header
    local clear_header = kong.service.request.clear_header

    if consumer and consumer.id then
        set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
    else
        clear_header(constants.HEADERS.CONSUMER_ID)
    end

    if consumer and consumer.custom_id then
        set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
    else
        clear_header(constants.HEADERS.CONSUMER_CUSTOM_ID)
    end

    if consumer and consumer.username then
        set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
    else
        clear_header(constants.HEADERS.CONSUMER_USERNAME)
    end

    if credential and credential.username then
        set_header(constants.HEADERS.CREDENTIAL_IDENTIFIER, credential.username)
        set_header(constants.HEADERS.CREDENTIAL_USERNAME, credential.username)
    else
        clear_header(constants.HEADERS.CREDENTIAL_IDENTIFIER)
        clear_header(constants.HEADERS.CREDENTIAL_USERNAME)
    end

    if credential then
        clear_header(constants.HEADERS.ANONYMOUS)
    else
        set_header(constants.HEADERS.ANONYMOUS, true)
    end
end


function HeaderAuthHandler:access(plugin_conf)
    kong.log.debug("start executing plugin header-auth")

    if plugin_conf.anonymous and kong.client.get_credential() then
        return
    end

    local username = kong.request.get_header(plugin_conf.header_name)

    if plugin_conf.anonymous and (username == nil or username =='') then
        local result,err = find_consumer(plugin_conf.anonymous)
        if err then
            return error(err)
        end
        if not result then
            return  kong.response.error(500, "invalid recorded consumer")
        end
        set_consumer(result)

        return
    end


    if username == nil or username =='' then
        kong.log.err("header is not set: ",plugin_conf.header_name)
        return  kong.response.error(401, "auth header is not set")
    end

    if plugin_conf.hide_credentials then
        kong.service.request.clear_header(plugin_conf.header_name)
    end

    local result,err = find_consumer(username)
    if err then
        return error(err)
    end
    if not result then
        return  kong.response.error(500, "invalid recorded consumer")
    end

    set_consumer(result)

end 

return HeaderAuthHandler