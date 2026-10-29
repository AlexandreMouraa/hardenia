tempo += 1;
var _pular = tempo > pode_pular && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || mouse_check_button_pressed(mb_left));
if (!saindo && (tempo >= duracao || _pular)) {
    saindo = true;
    room_goto(destino);
}
