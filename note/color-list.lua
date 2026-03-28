-- ========================================================
-- 🎨 48-Color Palette for Ricing (Vibe Coded Edition)
-- ========================================================

local M = {}

M.colors = {
  -- ==========================================
  -- 1. MONOCHROME & NEUTRALS (01-12) 灰阶与中性色
  -- ==========================================
  abyssal_void = { hex = '#0B090A', hsl = 'hsl(330, 10%, 4%)' },
  carbon_fiber = { hex = '#161A1D', hsl = 'hsl(206, 14%, 10%)' },
  obsidian_glass = { hex = '#343A40', hsl = 'hsl(210, 10%, 23%)' },
  terminal_ash = { hex = '#2B2D42', hsl = 'hsl(235, 21%, 21%)' },
  mech_armor = { hex = '#4A4E69', hsl = 'hsl(232, 17%, 35%)' },
  neural_static = { hex = '#415A77', hsl = 'hsl(212, 29%, 36%)' },
  titanium_pulse = { hex = '#778DA9', hsl = 'hsl(214, 22%, 56%)' },
  aluminium = { hex = '#ADB5BD', hsl = 'hsl(210, 11%, 71%)' },
  cloud_sync = { hex = '#E0E1DD', hsl = 'hsl(75, 5%, 87%)' },
  ghost_shell = { hex = '#F8F9FA', hsl = 'hsl(210, 20%, 98%)' },
  zero_gravity = { hex = '#E0FBFC', hsl = 'hsl(182, 74%, 93%)' },
  cyber_matrix = { hex = '#0A110D', hsl = 'hsl(145, 25%, 5%)' },

  -- ==========================================
  -- 2. WARM SPECTRUM (13-24) 红、橙、粉、黄
  -- ==========================================
  overheat_red = { hex = '#9B2226', hsl = 'hsl(358, 64%, 37%)' },
  mainframe_alert = { hex = '#EF233C', hsl = 'hsl(353, 86%, 54%)' },
  cyber_sangria = { hex = '#E63946', hsl = 'hsl(355, 78%, 56%)' },
  glitch_magenta = { hex = '#F72585', hsl = 'hsl(333, 93%, 56%)' },
  neon_bubblegum = { hex = '#FF71CE', hsl = 'hsl(321, 100%, 72%)' },
  solar_flare = { hex = '#FB5607', hsl = 'hsl(19, 97%, 51%)' },
  retro_apricot = { hex = '#F4A261', hsl = 'hsl(27, 87%, 67%)' },
  radioactive_tag = { hex = '#FF9F1C', hsl = 'hsl(35, 100%, 55%)' },
  stellar_dust = { hex = '#FFD166', hsl = 'hsl(42, 100%, 70%)' },
  cyber_mustard = { hex = '#E9C46A', hsl = 'hsl(43, 74%, 66%)' },
  voltage_yellow = { hex = '#FEE440', hsl = 'hsl(52, 99%, 62%)' },
  acid_leak = { hex = '#DFFF00', hsl = 'hsl(68, 100%, 50%)' },

  -- ==========================================
  -- 3. COOL SPECTRUM (25-36) 绿、青、蓝
  -- ==========================================
  neon_sulfur = { hex = '#CCFF33', hsl = 'hsl(75, 100%, 60%)' },
  synthetic_leaf = { hex = '#70E000', hsl = 'hsl(90, 100%, 44%)' },
  bio_lumine = { hex = '#38B000', hsl = 'hsl(101, 100%, 35%)' },
  matrix_phosphor = { hex = '#00FF41', hsl = 'hsl(135, 100%, 50%)' },
  toxic_matcha = { hex = '#84DCC6', hsl = 'hsl(165, 56%, 69%)' },
  circuit_path = { hex = '#2EC4B6', hsl = 'hsl(174, 62%, 47%)' },
  electric_cyan = { hex = '#0DF5E3', hsl = 'hsl(175, 92%, 51%)' },
  silicon_valley = { hex = '#90E0EF', hsl = 'hsl(190, 73%, 75%)' },
  quantum_flux = { hex = '#4CC9F0', hsl = 'hsl(194, 86%, 62%)' },
  neon_ice = { hex = '#00BBF9', hsl = 'hsl(195, 100%, 49%)' },
  nanotech_blue = { hex = '#0096C7', hsl = 'hsl(195, 100%, 39%)' },
  data_stream = { hex = '#4361EE', hsl = 'hsl(230, 83%, 60%)' },

  -- ==========================================
  -- 4. VIOLET & DEEP VOID (37-48) 紫、深蓝、虚空
  -- ==========================================
  lavender_mem = { hex = '#CDB4DB', hsl = 'hsl(278, 25%, 77%)' },
  cryptid_gold = { hex = '#C77DFF', hsl = 'hsl(274, 100%, 75%)' },
  hologram_violet = { hex = '#9D4EDD', hsl = 'hsl(273, 67%, 59%)' },
  plasma_burn = { hex = '#6A00F4', hsl = 'hsl(266, 100%, 48%)' },
  warp_speed = { hex = '#480CA8', hsl = 'hsl(263, 87%, 35%)' },
  void_purple = { hex = '#3A0CA3', hsl = 'hsl(258, 86%, 34%)' },
  neon_eva = { hex = '#B10DC9', hsl = 'hsl(292, 88%, 42%)' },
  deep_sea_cable = { hex = '#0077B6', hsl = 'hsl(201, 100%, 36%)' },
  kernel_panic = { hex = '#1D3557', hsl = 'hsl(215, 50%, 23%)' },
  midnight_protocol = { hex = '#14213D', hsl = 'hsl(221, 51%, 16%)' },
  deep_buffer = { hex = '#240046', hsl = 'hsl(271, 100%, 14%)' },
  event_horizon = { hex = '#000000', hsl = 'hsl(0, 0%, 0%)' },
}

--- 🛠️ 辅助函数：将 HEX 动态转换为 RGB 字符串 (彻底告别手动写错)
M.hex_to_rgb_str = function(hex)
  hex = hex:gsub('#', '')
  local r = tonumber('0x' .. hex:sub(1, 2))
  local g = tonumber('0x' .. hex:sub(3, 4))
  local b = tonumber('0x' .. hex:sub(5, 6))
  return string.format('rgb(%d, %d, %d)', r, g, b)
end

--- 🚀 核心功能：获取调色板数组，并按照 HSL 的 Hue (色相) 进行彩虹排序
M.get_palette_indexed = function()
  local indexed = {}
  for name, data in pairs(M.colors) do
    -- 动态补充 RGB 属性，节约代码空间且保证绝对准确
    data.name = name
    data.rgb = M.hex_to_rgb_str(data.hex)
    table.insert(indexed, data)
  end

  -- ⚙️ 排序算法：用正则抓取 'hsl(330,...' 里面的数字 330 进行比较
  table.sort(indexed, function(a, b)
    -- 提取出色相值 H，如果提取失败则默认当做 0
    local h1 = tonumber(a.hsl:match('hsl%((%d+)')) or 0
    local h2 = tonumber(b.hsl:match('hsl%((%d+)')) or 0

    -- 如果色相相同（比如两个都是红），则退化按亮度排（自己可以定制）
    return h1 < h2
  end)

  return indexed
end

return M
