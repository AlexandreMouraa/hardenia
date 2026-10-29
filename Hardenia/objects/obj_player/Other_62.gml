// Async HTTP: respostas da API. So as da tela de vitoria importam; os eventos
// de jogo sao "dispara e esquece"
var _id = async_load[? "id"];
if (_id != req_vitoria && _id != req_ranking) {
    exit;
}
// status 1 = ainda baixando
if (async_load[? "status"] == 1) {
    exit;
}

var _ok = async_load[? "status"] == 0 && async_load[? "http_status"] == 200;
var _dados = undefined;
if (_ok) {
    try {
        _dados = json_parse(async_load[? "result"]);
    } catch (_erro) {
        _ok = false;
    }
}

if (_id == req_vitoria) {
    req_vitoria = -1;
    if (_ok && vitoria_estado == "enviando") {
        vitoria_posicao = _dados.posicao;
        vitoria_total = _dados.total;
        vitoria_estado = "enviado";
        req_ranking = http_get(global.api_base + "/api/ranking?limite=5");
    } else if (vitoria_estado == "enviando") {
        vitoria_estado = "falhou";
    }
} else {
    req_ranking = -1;
    if (_ok) {
        vitoria_ranking = _dados.ranking;
    }
}
