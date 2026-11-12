if (patio_parado()) exit;
guarda_quebrada = max(0, guarda_quebrada - 1);
guarda_flash = max(0, guarda_flash - 1);
if (state == 0 && instance_exists(obj_player) && vendo) {
    // Giro limitado: o jogador consegue passar pelas costas sem o escudo virar instantaneamente.
    var _alvo = point_direction(x, y, obj_player.x, obj_player.y);
    guarda_dir = (guarda_dir + clamp(((_alvo - guarda_dir + 540) mod 360) - 180, -2, 2) + 360) mod 360;
} else if (state == 1 || state == 2) {
    guarda_dir = attack_dir;
}
event_inherited();
