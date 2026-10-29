// Rede: manda eventos de jogo e vitorias para a API do site (ranking e mapa
// de mortes). O codigo solto deste script roda uma vez, quando o jogo abre.

// versao mostrada no menu (bug reportado diz em qual versao foi). Ao lancar
// uma nova, trocar aqui e em deploy/VERSAO, e registrar no site (novidades)
#macro VERSAO_JOGO "0.5"

// no navegador a API fica no mesmo site; o build de Windows usa o endereco
// publico. -api <url> troca o endereco (teste local) e liga a rede no robo
global.api_base = (os_browser != browser_not_a_browser) ? "" : "https://hardenia.177-136-207-112.sslip.io";
global.api_forcada = false;
for (var _i = 1; _i < parameter_count(); _i++) {
    if (parameter_string(_i) == "-api") {
        global.api_base = parameter_string(_i + 1);
        global.api_forcada = true;
    }
}
global.plataforma = (os_browser != browser_not_a_browser) ? "web" : "windows";

// identifica a sessao (do abrir ao fechar o jogo) sem dado pessoal. md5 do
// relogio em vez de random: randomize() mudaria a semente que o jogo usa
global.sessao = md5_string_utf8(string(date_current_datetime()) + "|" + string(get_timer()));

// tempo da run em frames: pausa nao conta, e frame e o mesmo em PC lento ou rapido
global.run_frames = 0;

// o robo de teste (-autotest) nao suja o ranking, a nao ser com -api
function rede_ativa() {
    return !instance_exists(obj_autotest) || global.api_forcada;
}

// devolve o id da requisicao (para o Async HTTP) ou -1 sem rede
function rede_post(_rota, _dados) {
    if (!rede_ativa()) {
        return -1;
    }
    _dados.plataforma = global.plataforma;
    _dados.sessao = global.sessao;
    return http_post_string(global.api_base + _rota, json_stringify(_dados));
}

// tipo: "inicio", "morte" ou "sala" (sala limpa)
function rede_evento(_tipo, _dados = undefined) {
    if (is_undefined(_dados)) {
        _dados = {};
    }
    _dados.tipo = _tipo;
    _dados.sala = room_get_name(room);
    return rede_post("/api/evento", _dados);
}

// tempo de jogo: frames na velocidade de projeto (60). Nao usa a velocidade
// atual porque o robo acelera o jogo, e PC lento roda menos frames por segundo
function frames_para_ms(_frames) {
    return round(_frames * 1000 / 60);
}

// "m:ss"
function tempo_texto(_ms) {
    var _s = _ms div 1000;
    var _seg = _s mod 60;
    return string(_s div 60) + ":" + (_seg < 10 ? "0" : "") + string(_seg);
}

// nome do ranking: letras sem acento, numeros, espaco, ponto e traco, ate 16.
// Sem acento porque a fonte padrao do jogo nao tem esses caracteres
function nome_filtrado(_texto) {
    var _ok = "";
    for (var _i = 1; _i <= string_length(_texto) && string_length(_ok) < 16; _i++) {
        var _c = string_char_at(_texto, _i);
        if (string_lettersdigits(_c) != "" || _c == " " || _c == "." || _c == "-" || _c == "_") {
            _ok += _c;
        }
    }
    return _ok;
}
