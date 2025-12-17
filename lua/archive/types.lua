--- TASK(20251217-143206): Extend type system
--- TASK(20251217-171304): Add good docs

--- TaskStyle describes vistual style of the segment
---@class archive.TaskStyle
---@field fg string Color of the text in hex (example, "#ffd700")
---@field bg string Color of the background in hex (example, "#ffd700")
---@field bold boolean? If true text will be bold, by default true

--- TaskStyles holds options for all parts of the task itself
--- stats - additional info from task file (STATUS, CREATION DATE and etc)
--- task - task string itself (TASK(date):)
--- desc - description string (TASK(date): desc)
---@class archive.TaskStyles
---@field status archive.TaskStyle Style for statistics
---@field task archive.TaskStyle Style for task string
---@field desc archive.TaskStyle Style for description string

--- TaskSource describes source from which task is created
---@class archive.TaskSource
---@field priority integer Default Priority for the task source

---@class archive.TaskTag
---@field name string
---@field values (string|number)[]?
---@field default_value (string | number | fun(arg: archive.Task): string|number)?

--- TaskConfig holds all options needed for describing task
---@class archive.TaskConfig
---@field colors archive.TaskStyles
---@field tags table<string, archive.TaskTag>
---@field tags_order string[]
---@field source table<string, archive.TaskSource>

---@class archive.SearchConfig
---@field command string
---@field args string[]
---@field root_markers string[]

---@class archive.Options
---@field storage string Name of the storage dir
---@field task archive.TaskConfig
---@field search archive.SearchConfig

---@class archive.SearchRgResult
---@field filename string
---@field lnum number
---@field col number
---@field text string

---@alias archive.StatValue number|string

--- Task describes one task
---@class archive.Task
---@field task_name string Represents task name in HUID notation
---@field source string
---@field desc string Task description
---@field creation_time integer
---@field stats table<string, archive.StatValue>
