
--
--
-- User: ungle
-- Date: 2021/3/11
-- Time: 12:00
--
--

local typedefs = require "kong.db.schema.typedefs"

-- Grab pluginname from module name

local schema = {
    name = "header-auth",
    fields = {
        -- the 'fields' array is the top-level entry with fields defined by Kong
        { consumer = typedefs.no_consumer },
        { protocols = typedefs.protocols_http },
        { config = {
            -- The 'config' record is the custom part of the plugin schema
            type = "record",
            fields = {
                -- a standard defined field (typedef), with some customizations
                { header_name = typedefs.header_name {
                    required = true,
                    default = "x-conusmer-name" } },
                { anonymous =  { type = "string" }, },
                { hide_credentials = { type = "boolean", required = true, default = false }, },
            },
        },
        },
    },
}

return schema

