global.hitstop = 1;
if (global.game_paused) {
    exit;
}
tempo += 1;
var _pular = tempo > pode_pular && !instance_exists(obj_autotest) && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || mouse_check_button_pressed(mb_left));
if (tempo >= duracao || _pular) {
    instance_destroy();
}
