# futviral

[![futviral — radar de fútbol](guia/assets/banner-es.jpg)](https://inematds.github.io/futviral/guia/es/)

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

## Qué es

futviral hace, solo, videos cortos (9:16) con el resumen de lo que dijeron los 10 mayores canales de fútbol de YouTube: Brasileirão, fútbol europeo, mercado de fichajes, polémicas y negocios del fútbol. Mira los videos a través de la transcripción, separa los números y los hechos con la fuente de cada uno y arma un video con números grandes, sellos (RUMOR, NEGOCIANDO, FECHADO (cerrado), POLÊMICA (polémica)) y Nei comentando (avatar). El rumor se trata como rumor, ningún club tiene preferencia y las apuestas no entran. Funciona en una computadora con GPU, con la suscripción de Claude Code y de HeyGen. Es hermano de [advviral](https://github.com/inematds/advviral), de [saudeviral](https://github.com/inematds/saudeviral) y de [finviral](https://github.com/inematds/finviral) (mismo motor, otro tema).

## 📖 Guía de uso

Guía completa (landing + paso a paso): **https://inematds.github.io/futviral/guia/es/**

## Los 10 canales

Elegidos el 26/10/2026 con medición propia (yt-dlp, mediana de vistas de los últimos 15 videos, canal activo y hablado). Detalles en [`pesquisa/canais.md`](pesquisa/canais.md) (en portugués); lista viva en `canais.json`.

Eurão · Jovem Pan Esportes · Jozão · Fabrizio Romano · Chico Garcia · Tode · Fred Caldeira · TiaGOL · Canal do Nicola · Mauro Cezar.

## El proceso, de principio a fin

| # | Paso | Comando | Quién lo hace |
|---|---|---|---|
| 1 | Lista los videos de los canales del período (solo metadatos) | `coleta/listar.py` (llamado por `auto/rodar.sh`) | ⚙️ script |
| 2 | Elige 1 video por canal (el más visto), sin repetir un video ya usado | `auto/rodar.sh` + `auto/usados.py` | ⚙️ script |
| 3 | Toma los subtítulos de YouTube (segundos); si no los hay, descarga el audio y transcribe en local (inemavox, Whisper large-v3; inglés para Fabrizio) | `coleta/transcrever.sh` + `coleta/legenda_yt.py` | ⚙️ script |
| 4 | Escribe `base.md` (hecho + fragmento literal), `roteiro.json` y `legenda.txt` | `claude -p` con `auto/roteiro.md` | 🤖 `claude -p` |
| 5 | Verifica fragmentos, números escritos con letras, 5+ temas, aviso de rumor, sin apuestas; 1 corrección | `auto/checar.py` | ⚙️ script |
| 6 | Avatar de Nei en el estudio de HeyGen (suscripción); si falla, foto + voz de Nei | `motor/avatar_heygen.sh` / `motor/narrar.py` | ⚙️ script |
| 7 | Renderiza el video (palco.html cuadro por cuadro) y compone el avatar | `motor/gerar_cena.py` + `motor/compor_avatar.sh` | ⚙️ script |
| 8 | Generación a las 9 h: el video va al bot como vista previa. Al mediodía se publica en YouTube **Inema Pro (lives12)** y se manda el enlace al bot (`touch <edición>/SEGURAR` lo retiene) | `auto/publicar.sh` + `auto/publicar-pendente.sh` (yt-pubx) | ⚙️ timer 09:00 / 12:00 |
| 9 | Sáb/dom: video largo 16:9 "A semana explicada" (La semana explicada) | `auto/roteiro-longo.md` → `auto/longo.sh` | 🤖 + ⚙️ |
| 10 | Aprobar el formato, agregar/quitar canales, activar la agenda | `canais.json`, `systemd/` | 🧠 sesión con Nei |

Ronda a mano:

```bash
auto/rodar.sh diario 2026-10-26                 # ronda completa (avatar + lives12 + bot)
SEM_AVATAR=1 auto/rodar.sh diario 2026-10-26    # versión con foto, solo para el bot
REUSAR_ROTEIRO=1 auto/rodar.sh diario 2026-10-26  # rehace avatar/video/publicación con el guion ya aprobado
```

Agenda (`systemd/futviral-*.timer`, activada el 26/10/2026): generación a las 09:00 (diario de lunes a viernes, semanal el sábado, domingo el domingo) y publicación a las 12:00.

## Reglas de cada video

- Todo hecho tiene la fuente (canal, fecha, título) en pantalla y un fragmento literal de la transcripción en `base.md`.
- "Rumor só vale quando o clube confirma" (el rumor solo vale cuando el club lo confirma): una transferencia es "rumor" o "negociando" hasta que el club la confirme.
- Sin hinchar por nadie: todo se atribuye a quien lo dijo.
- Sin apuestas: nada de bets, cuotas ni pronósticos. El portón lo reprueba.
- Sin jugadas, goles, imágenes de partidos ni escudos de clubes (derechos de transmisión).
- Habla en el tono de Nei, dirigiéndose al espectador con "você", con los números escritos con letras. Al final: una pregunta para comentar y el CTA de inema.club.
- HeyGen solo por el estudio de la suscripción. La oferta de cambio de plan siempre se rechaza.

## Licencia

MIT.
