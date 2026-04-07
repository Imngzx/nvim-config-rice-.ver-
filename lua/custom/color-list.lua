-- ========================================================
-- 🎨 72-Color Palette for Ricing (Vibe Coded Edition)
-- ========================================================

local M = {}

M.colors = {
  -- ==========================================
  -- 1. MONOCHROME & NEUTRALS (灰阶与中性色)
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
  quantum_silver = { hex = '#C0C0C0', hsl = 'hsl(0, 0%, 75%)' },
  moon_rock = { hex = '#8C92AC', hsl = 'hsl(210, 15%, 61%)' },
  deep_space = { hex = '#0D1117', hsl = 'hsl(216, 28%, 7%)' },

  -- ==========================================
  -- 2. WARM SPECTRUM (红、橙、粉、黄)
  -- ==========================================
  overheat_red = { hex = '#9B2226', hsl = 'hsl(358, 64%, 37%)' },
  mainframe_alert = { hex = '#EF233C', hsl = 'hsl(353, 86%, 54%)' },
  cyber_sangria = { hex = '#E63946', hsl = 'hsl(355, 78%, 56%)' },
  blood_moon = { hex = '#660000', hsl = 'hsl(0, 100%, 20%)' },
  glitch_magenta = { hex = '#F72585', hsl = 'hsl(333, 93%, 56%)' },
  neon_bubblegum = { hex = '#FF71CE', hsl = 'hsl(321, 100%, 72%)' },
  synthwave_pink = { hex = '#FF00FF', hsl = 'hsl(300, 100%, 50%)' },
  sakura_drop = { hex = '#FFB7B2', hsl = 'hsl(348, 100%, 85%)' },
  solar_flare = { hex = '#FB5607', hsl = 'hsl(19, 97%, 51%)' },
  magma_burst = { hex = '#FF4500', hsl = 'hsl(16, 100%, 50%)' },
  retro_apricot = { hex = '#F4A261', hsl = 'hsl(27, 87%, 67%)' },
  radioactive_tag = { hex = '#FF9F1C', hsl = 'hsl(35, 100%, 55%)' },
  cyber_peach = { hex = '#FFDAB9', hsl = 'hsl(28, 100%, 86%)' },
  stellar_dust = { hex = '#FFD166', hsl = 'hsl(42, 100%, 70%)' },
  cyber_mustard = { hex = '#E9C46A', hsl = 'hsl(43, 74%, 66%)' },
  cyber_gold = { hex = '#FFD700', hsl = 'hsl(51, 100%, 50%)' },
  voltage_yellow = { hex = '#FEE440', hsl = 'hsl(52, 99%, 62%)' },
  acid_leak = { hex = '#DFFF00', hsl = 'hsl(68, 100%, 50%)' },

  -- ==========================================
  -- 3. COOL SPECTRUM (绿、青、蓝)
  -- ==========================================
  neon_sulfur = { hex = '#CCFF33', hsl = 'hsl(75, 100%, 60%)' },
  synthetic_leaf = { hex = '#70E000', hsl = 'hsl(90, 100%, 44%)' },
  bio_lumine = { hex = '#38B000', hsl = 'hsl(101, 100%, 35%)' },
  matrix_phosphor = { hex = '#00FF41', hsl = 'hsl(135, 100%, 50%)' },
  toxic_matcha = { hex = '#84DCC6', hsl = 'hsl(165, 56%, 69%)' },
  abyss_mint = { hex = '#00FA9A', hsl = 'hsl(157, 100%, 49%)' },
  circuit_path = { hex = '#2EC4B6', hsl = 'hsl(174, 62%, 47%)' },
  electric_cyan = { hex = '#0DF5E3', hsl = 'hsl(175, 92%, 51%)' },
  silicon_valley = { hex = '#90E0EF', hsl = 'hsl(190, 73%, 75%)' },
  glacier_ice = { hex = '#A8E6CF', hsl = 'hsl(168, 54%, 78%)' },
  quantum_flux = { hex = '#4CC9F0', hsl = 'hsl(194, 86%, 62%)' },
  neon_ice = { hex = '#00BBF9', hsl = 'hsl(195, 100%, 49%)' },
  nanotech_blue = { hex = '#0096C7', hsl = 'hsl(195, 100%, 39%)' },
  deep_ocean = { hex = '#00509E', hsl = 'hsl(210, 100%, 31%)' },
  data_stream = { hex = '#4361EE', hsl = 'hsl(230, 83%, 60%)' },
  hologram_blue = { hex = '#00BFFF', hsl = 'hsl(195, 100%, 50%)' },

  -- ==========================================
  -- 4. VIOLET & DEEP VOID (紫、深蓝、虚空)
  -- ==========================================
  lavender_mem = { hex = '#CDB4DB', hsl = 'hsl(278, 25%, 77%)' },
  cryptid_gold = { hex = '#C77DFF', hsl = 'hsl(274, 100%, 75%)' },
  hologram_violet = { hex = '#9D4EDD', hsl = 'hsl(273, 67%, 59%)' },
  plasma_burn = { hex = '#6A00F4', hsl = 'hsl(266, 100%, 48%)' },
  amethyst_core = { hex = '#9966CC', hsl = 'hsl(270, 50%, 60%)' },
  warp_speed = { hex = '#480CA8', hsl = 'hsl(263, 87%, 35%)' },
  void_purple = { hex = '#3A0CA3', hsl = 'hsl(258, 86%, 34%)' },
  neon_eva = { hex = '#B10DC9', hsl = 'hsl(292, 88%, 42%)' },
  dark_matter = { hex = '#301934', hsl = 'hsl(285, 35%, 15%)' },
  deep_sea_cable = { hex = '#0077B6', hsl = 'hsl(201, 100%, 36%)' },
  kernel_panic = { hex = '#1D3557', hsl = 'hsl(215, 50%, 23%)' },
  midnight_protocol = { hex = '#14213D', hsl = 'hsl(221, 51%, 16%)' },
  deep_buffer = { hex = '#240046', hsl = 'hsl(271, 100%, 14%)' },
  event_horizon = { hex = '#000000', hsl = 'hsl(0, 0%, 0%)' },
}

M.hex_to_rgb_str = function(hex)
  hex = hex:gsub('#', '')
  local r = tonumber('0x' .. hex:sub(1, 2))
  local g = tonumber('0x' .. hex:sub(3, 4))
  local b = tonumber('0x' .. hex:sub(5, 6))
  return string.format('rgb(%d, %d, %d)', r, g, b)
end

M.get_palette_indexed = function()
  local indexed = {}
  for name, data in pairs(M.colors) do
    data.name = name
    data.rgb = M.hex_to_rgb_str(data.hex)
    table.insert(indexed, data)
  end

  table.sort(indexed, function(a, b)
    local h1 = tonumber(a.hsl:match('hsl%((%d+)')) or 0
    local h2 = tonumber(b.hsl:match('hsl%((%d+)')) or 0
    return h1 < h2
  end)

  return indexed
end

return M
