surgir = min(1, surgir + 1 / 40);
tempo += 1;
var _pular = tempo > pode_pular && !instance_exists(obj_autotest) && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("J")) || mouse_check_button_pressed(mb_left));
var _tempo_carta = instance_exists(obj_autotest) ? 40 : por_carta;
if (tempo >= _tempo_carta || _pular) {
    tempo = 0;
    carta += 1;
    // a ultima e a dos creditos
    if (carta > array_length(cartas) && !fim) {
        fim = true;
        // o que foi digitado para passar o texto nao pode cair no campo do nome
        keyboard_string = "";
        with (obj_player) {
            final_pausa = 20;
        }
        instance_destroy();
    }
}
