-- ~/.hammerspoon/init.lua

require('hs.ipc')
hs.window.animationDuration = 0

local windows = require('windows')
local network = require('network')
local keys    = require('keys')
local mouse   = require('mouse')

keys.bind()
windows.startWatcher()
network.startWatcher()
mouse.startWatcher()
