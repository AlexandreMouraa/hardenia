// a bomba vem do alto: passa por cima de todo mundo
if (bomba && state == 1) {
    bomba_desenhar(zona.cx, zona.cy, 1 - state_timer / ataque.aviso, state_timer);
}
