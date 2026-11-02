// As duas fontes do jogo, montadas de folhas de letras (tools/gerar_fontes.py): saem iguais no
// Windows e no navegador, e tem acento. A fonte padrao do GameMaker e diferente em cada um.
// Os numeros de tamanho do jogo foram medidos com a fonte padrao: as folhas sao maiores que ela
// para a letra ficar lisa em tela grande, e as contas abaixo trazem de volta para aquele tamanho.
// A ordem das letras e a mesma da folha.
#macro FONTE_ACENTOS "ÀÁÂÃÇÉÊÍÓÔÕÚÜàáâãçéêíóôõúü"
#macro FONTE_LETRAS " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" + FONTE_ACENTOS
#macro FONTE_ESCALA 0.5
#macro TITULO_ESCALA 0.1667

global.fonte_texto = -1;
global.fonte_titulo = -1;

function fontes_preparar() {
    global.fonte_texto = font_add_sprite_ext(spr_fonte_texto, FONTE_LETRAS, true, 0);
    global.fonte_titulo = font_add_sprite_ext(spr_fonte_titulo, FONTE_LETRAS, true, 0);
}

// a letra e lisa e o jogo e pixelado: so a letra e filtrada, senao fica serrilhada ao encolher
function texto(_x, _y, _s, _ex, _ey, _ang) {
    if (global.fonte_texto == -1) {
        fontes_preparar();
    }
    draw_set_font(global.fonte_texto);
    gpu_set_tex_filter(true);
    draw_text_transformed(_x, _y, _s, _ex * FONTE_ESCALA, _ey * FONTE_ESCALA, _ang);
    gpu_set_tex_filter(false);
}

// _sep e _largura: em tamanho de letra sem escala, como no draw_text_ext_transformed
function texto_ext(_x, _y, _s, _sep, _largura, _ex, _ey, _ang) {
    if (global.fonte_texto == -1) {
        fontes_preparar();
    }
    draw_set_font(global.fonte_texto);
    gpu_set_tex_filter(true);
    draw_text_ext_transformed(_x, _y, _s, _sep / FONTE_ESCALA, _largura / FONTE_ESCALA, _ex * FONTE_ESCALA, _ey * FONTE_ESCALA, _ang);
    gpu_set_tex_filter(false);
}

// a frase grande de cada tela, na fonte gotica. Maiusculas juntas nela ficam dificeis de ler:
// escreva "Voce morreu", nao "VOCE MORREU". _esc: o mesmo tamanho que seria usado em texto()
function titulo(_x, _y, _s, _esc) {
    if (global.fonte_titulo == -1) {
        fontes_preparar();
    }
    draw_set_font(global.fonte_titulo);
    gpu_set_tex_filter(true);
    draw_text_transformed(_x, _y, _s, _esc * TITULO_ESCALA, _esc * TITULO_ESCALA, 0);
    gpu_set_tex_filter(false);
}
