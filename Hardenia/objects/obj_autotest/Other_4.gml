tempo_sala = 0;
espera = 0;
estava_morto = false;
sala_limpa_logada = false;
sem_caminho_logado = false;
travado = 0;
quieto = 0;
ocioso = 0;
forcar_caminho = 0;
andou_frames = 0;
mov_h = 0;
mov_v = 0;
desvio_frames = 0;
proximo_x = -1;
inimigos_antes = instance_number(obj_enemy);
if (room != sala_anterior) {
    mortes_sala = 0;
    sala_anterior = room;
}

if (grade != -1) {
    mp_grid_destroy(grade);
    grade = -1;
}

if (room == Room_Menu) {
    exit;
}

log("sala_inicio", "tentativa=" + string(global.tentativas) + " inimigos=" + string(inimigos_antes));

if (testar_formas) {
    if (!formas_testadas) {
        formas_testadas = true;
        testar_zonas();
    }
    var _forma = 0;
    with (obj_enemy) {
        ataque = other.ataques_formas[_forma mod 4];
        hp = 12;
        _forma += 1;
    }
}

// grade de navegacao: cada parede inflada pelo tamanho do jogador, assim o
// caminho e para o centro dele
grade = mp_grid_create(0, 0, ceil(room_width / 8), ceil(room_height / 8), 8, 8);
with (obj_wall) {
    mp_grid_add_rectangle(other.grade, bbox_left - 8, bbox_top - 14, bbox_right + 8, bbox_bottom + 14);
}

// checagens de level design, uma vez por sala
var _nome = room_get_name(room);
if (!variable_struct_exists(salas_checadas, _nome) && instance_exists(obj_player)) {
    variable_struct_set(salas_checadas, _nome, true);
    var _p = instance_find(obj_player, 0);
    with (_p) {
        if (place_meeting(x, y, obj_wall)) {
            other.log("ALERTA_jogador_nasce_na_parede", string(x) + "," + string(y));
        }
    }
    with (obj_enemy) {
        if (place_meeting(x, y, obj_wall)) {
            other.log("ALERTA_inimigo_na_parede", object_get_name(object_index) + " em " + string(x) + "," + string(y));
        }
        if (!other.tem_caminho(_p.x, _p.y, x, y)) {
            other.log("ALERTA_inimigo_sem_caminho", object_get_name(object_index) + " em " + string(x) + "," + string(y));
        }
    }
    var _s = saida_adiante();
    if (_s != noone) {
        var _sx = (_s.bbox_left + _s.bbox_right) / 2;
        var _sy = (_s.bbox_top + _s.bbox_bottom) / 2;
        if (!tem_caminho(_p.x, _p.y, _sx, _sy)) {
            log("ALERTA_saida_sem_caminho", object_get_name(_s.object_index) + " em " + string(_sx) + "," + string(_sy));
        }
    }
}
