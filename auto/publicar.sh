#!/usr/bin/env bash
# Publica um vídeo do futviral no YouTube Inema Club24 (lives24) pelo yt-pubx e manda SEMPRE ao bot v3 (com o link).
# uso: auto/publicar.sh <video.mp4> <pasta-da-edicao> <rotulo> [extra-da-legenda]
#   título = 1ª linha de <ed>/legenda.txt (curto vertical recebe #Shorts e sai sem thumb; o longo ganha thumb do Codex).
#   SEM_YT=1 só manda ao bot; SEM_BOT=1 simula o envio ao bot (teste).
# Autorizado pelo Nei em 10/10/2026: "pode sempre criar direto com o avatar … publicar … e sempre manda para o bot também".
set -uo pipefail
# systemd não tem ~/.npm-global/bin no PATH e pegava o codex velho de /usr/bin (0.116), que não lê o config.toml do novo (10/10/2026)
export PATH="$HOME/.npm-global/bin:$PATH"
V="$1"; E="$(cd "$2" && pwd)"; ROT="$3"; EXTRA="${4:-}"
PL="$E/publicar-$(printf %s "$ROT" | tr -c 'A-Za-z0-9-' _).log"  # o rótulo traz a data dd/mm/aaaa: barra no nome quebrava o log (10/10/2026)
BOT="$HOME/projetos/refazvideo/ferramentas/enviar_bot_v3.mjs"
DRY=""; [ "${SEM_BOT:-}" = 1 ] && DRY=--dry-run
# Publicação adiada (Nei, 26/10/2026: "a publicação pode ser meio-dia, já a geração às 9 da manhã").
# Com PUBLICAR_AS=HH:MM (vem do serviço), o vídeo pronto fica pendente (sem prévia no v3 desde 06/11/2026);
# o auto/publicar-pendente.sh (timer das 12:00) publica no lives24. Para segurar: crie <ed>/SEGURAR.
if { [ -n "${PUBLICAR_AS:-}" ] || [ -e "$E/SEGURAR" ]; } && [ "${SEM_YT:-}" != 1 ] && [ -z "${PUBLICANDO_PENDENTE:-}" ]; then
  QUANDO="às ${PUBLICAR_AS:-12:00}"; [ -e "$E/SEGURAR" ] && QUANDO="só quando o Nei liberar (rm $E/SEGURAR e rodar auto/publicar-pendente.sh)"
  printf '%s\n%s\n%s\n' "$V" "$ROT" "$EXTRA" > "$E/PUBLICAR_PENDENTE.$(basename "$V" .mp4)"
  # prévia não vai mais ao v3 (Nei, 06/11/2026: v3 só quando ele pedir ou der erro); para segurar: touch $E/SEGURAR
  echo "pendente: publica $QUANDO"; exit 0
fi
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$V" | cut -d. -f1)
W=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$V")
TIT=$(head -1 "$E/legenda.txt" | cut -c1-90)
[ "$W" -lt 1000 ] && TIT="$TIT #Shorts"
URL=""
if [ "${SEM_YT:-}" != 1 ]; then
  CTX="futviral (Inema Club24): resumo do que os maiores canais de futebol do YouTube disseram (Brasileirão, futebol europeu, mercado da bola, polêmicas), com a fonte de cada fato na tela e o Nei Maldaner comentando. Rumor de transferência é rumor até o clube confirmar. Sem apostas. Curso gratuito de gestão de agentes de IA em https://inema.club. Não cite outros canais na descrição além dos influenciadores do vídeo."
  timeout 2400 "$HOME/projetos/yt-pubx/yt-pubx" publicar "$V" --canal lives24 --title "$TIT" --contexto "$CTX" \
      --contexto-arquivo "$E/legenda.txt" > "$PL" 2>&1
  URL=$(grep -o 'https://www.youtube.com/watch?v=[A-Za-z0-9_-]*\|https://youtu.be/[A-Za-z0-9_-]*' "$PL" | tail -1)
fi
if [ -n "$URL" ]; then ST="publicado no Inema Club24 (lives24): $URL"
elif [ "${SEM_YT:-}" = 1 ]; then ST="(sem YouTube nesta rodada)"
else ST="⚠ NÃO publicou no lives24: $(grep -h -i 'erro\|error\|quota\|limit' "$PL" | tail -1 | cut -c1-200)"; fi
if [ -z "$URL" ]; then  # (Nei, 06/11/2026: aviso do YouTube no v3 só se der erro)
  VB="$V"  # bot aceita até ~49 MB: acima disso vai uma cópia 720p (o YouTube recebe o original)
  if [ "$(stat -c %s "$V")" -gt 48000000 ]; then
    VB="${V%.mp4}-720p.mp4"
    RAIZ="$(cd "$(dirname "$0")/.." && pwd)"  # encode na vaga render da máquina (motor/vaga.sh, 09/11/2026)
    RENDER_ESPERA_MIN="${RENDER_ESPERA_MIN:-30}" bash "$RAIZ/motor/vaga.sh" render "$(basename "$RAIZ")-720p" \
      ffmpeg -v error -y -i "$V" -vf "scale=-2:720" -c:v libx264 -crf 27 -preset medium -c:a aac -b:a 128k -movflags +faststart "$VB"
  fi
  rm -f "$VB.envio-v3.json"
  node "$BOT" $DRY "$VB" "futviral · $ROT · ${DUR}s
$ST
$(head -c 600 "$E/legenda.txt")$EXTRA" || echo "falhou o envio ao bot"
fi
echo "$ST"
# futviral ainda não vai ao TikTok/Instagram (metricool-pub2 não configurado para ele).
