#!/usr/bin/env bash
# Publica no lives24 os vídeos que a geração das 9h deixou pendentes (<ed>/PUBLICAR_PENDENTE.<video>).
# Timer das 12:00 (Nei, 26/10/2026). <ed>/SEGURAR impede a publicação daquela edição (avisa no bot).
# uso: auto/publicar-pendente.sh            (todas as pendentes dos últimos 2 dias)
set -uo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
BOT="$HOME/projetos/refazvideo/ferramentas/enviar_bot_v3.mjs"
exec 9>"$RAIZ/auto/.publicando"; flock -n 9 || { echo "já publicando"; exit 0; }
n=0
for P in $(find "$RAIZ/edicoes" -maxdepth 2 -name 'PUBLICAR_PENDENTE.*' -mtime -2 | sort); do
  E="$(dirname "$P")"
  if [ -e "$E/SEGURAR" ]; then
    echo "segurado: $E"; mv "$P" "$P.segurado"
    echo "futviral: $(basename "$E") segurado (SEGURAR), não foi ao ar" > "$E/aviso-segurado.txt"
    node "$BOT" "$E/aviso-segurado.txt" "futviral · $(basename "$E") · segurado, não publicado" || true
    continue
  fi
  V=$(sed -n 1p "$P"); ROT=$(sed -n 2p "$P"); EXTRA=$(sed -n '3,$p' "$P")
  [ -s "$V" ] || { echo "sem vídeo: $V"; continue; }
  echo "publicando $V"
  PUBLICANDO_PENDENTE=1 bash "$RAIZ/auto/publicar.sh" "$V" "$E" "$ROT" "$EXTRA" && mv "$P" "$P.feito"
  n=$((n+1))
done
echo "$n publicados $(date '+%F %T')"
