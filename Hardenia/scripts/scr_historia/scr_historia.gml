// A historia na tela: abertura, final e as frases que mudam com as tentativas. Este e o lugar para
// o grupo mexer no texto, sem precisar entender o resto do codigo. Fala dos Caidos e do rei: em
// scr_tecnicas. Frases de morte por inimigo: em scr_mapa.
// so na primeira vez que o jogo abre neste aparelho (scr_salvo)
global.abertura_vista = false;
global.abertura = [
    "Há anos Hardenia manda seus guerreiros ao trono.",
    "Os mais fortes foram primeiro. Nenhum voltou.",
    "Sobrou você: o último, e o mais fraco de todos.",
    "Sem poderes. Sem armadura. Sem arma mágica.\nSó uma coisa que os outros não tinham: você não para de voltar.",
];
// equipe: mesma lista do site
global.creditos_equipe = "Alexandre Moura, Gabriel (Woooly), William e Cristielly";

// o final muda com o tanto que custou chegar la
function final_cartas() {
    var _n = global.tentativas;
    var _custo = "";
    if (_n == 1) {
        _custo = "Na primeira tentativa. Ninguém vai acreditar.";
    } else if (_n <= 5) {
        _custo = "Foram " + string(_n) + " tentativas. Mais rápido que todos os que vieram antes.";
    } else if (_n <= 20) {
        _custo = "Foram " + string(_n) + " tentativas. Nenhum dos outros chegou a tentar duas.";
    } else {
        _custo = "Foram " + string(_n) + " tentativas. Nenhum guerreiro morreu tanto. Nenhum voltou tanto.";
    }
    return [
        "O rei caiu. E com ele, todos os que ele levantou.",
        "Ele também veio ao trono um dia, para acabar com a guerra.\nTambém foi o último. Também era forte. Só não soube voltar.",
        _custo,
        "O mais fraco de todos foi o único que não parou.",
    ];
}

// a cada tantas mortes na mesma sessao, a frase da tela de morte e esta. Sem frase: "" (scr_mapa)
function frase_de_marco(_tentativa) {
    switch (_tentativa) {
        case 5: return "Cinco vezes. O mais forte do reino morreu uma só.";
        case 10: return "Dez mortes. Ninguém tinha chegado a tanto, porque ninguém voltava.";
        case 25: return "Vinte e cinco. Os Caídos já sabem o meu nome.";
        case 50: return "Cinquenta vezes. O rei também está contando.";
        case 100: return "Cem. Quem é o morto aqui?";
    }
    return "";
}

// ---------- marcas de morte: onde o guerreiro caiu antes, no chao de cada sala ----------
// { nome da sala: [[x, y], ...] }. Zera ao abrir o jogo. Teto para a sala nao virar um cemiterio
#macro MARCAS_POR_SALA 40
global.marcas_morte = {};

function marca_guardar(_x, _y) {
    var _nome = room_get_name(room);
    if (!variable_struct_exists(global.marcas_morte, _nome)) {
        variable_struct_set(global.marcas_morte, _nome, []);
    }
    var _lista = variable_struct_get(global.marcas_morte, _nome);
    array_push(_lista, [round(_x), round(_y)]);
    if (array_length(_lista) > MARCAS_POR_SALA) {
        array_delete(_lista, 0, 1);
    }
}
