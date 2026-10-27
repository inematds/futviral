#!/usr/bin/env bash
# Transcrição de cada id da lista: legenda do YouTube primeiro (yt-dlp, ~3 s, sem GPU); se não houver, baixa o áudio (inemavox) e usa o Whisper local.
# uso: transcrever.sh id1 id2 ...   -> $TX/<id>/transcript.txt + $TX/<id>/fonte (youtube|whisper)  (TX padrão: ~/projetos/output/futviral/coleta/tx, fora do repo)
# Legenda primeiro a pedido do Nei (26/10/2026): "usando o yt quando tiver". SO_WHISPER=1 força o Whisper.
set -uo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
TX="${TX:-$HOME/projetos/output/futviral/coleta/tx}"
VOX="$HOME/projetos/inemavox"
MODELO="${MODELO:-large-v3}"
for id in "$@"; do
  D="$TX/$id"; mkdir -p "$D"
  if ls "$D"/*.txt >/dev/null 2>&1; then echo "já tem $id"; continue; fi
  L=$(cat "$D/lang" 2>/dev/null || echo pt)  # língua do canal (canais.json "lang"), gravada pelo rodar.sh
  if [ "${SO_WHISPER:-}" != 1 ]; then
    echo "== $id legenda do YouTube ($L) $(date +%T)"
    rm -f "$D"/yt.*.json3; J=""
    # uma língua por pedido (a original do canal) e pausa entre tentativas: várias línguas seguidas dão 429 do YouTube
    for tent in "$L-orig" "$L" "$L-orig"; do
      timeout 90 yt-dlp --skip-download --no-warnings --write-auto-subs --write-subs --sub-langs "$tent" \
        --sub-format json3 -o "$D/yt.%(ext)s" "https://www.youtube.com/watch?v=$id" >> "$D/legenda.log" 2>&1
      J=$(ls "$D"/yt.*.json3 2>/dev/null | head -1); [ -n "$J" ] && break
      sleep 8
    done
    if [ -n "$J" ] && python3 "$AQUI/legenda_yt.py" "$J" "$D/transcript.txt" >> "$D/legenda.log" 2>&1; then
      echo youtube > "$D/fonte"; echo "ok $id (legenda)"; continue
    fi
    rm -f "$D/transcript.txt"; echo "sem legenda $id: vai pelo Whisper"
  fi
  mkdir -p "$D/audio"
  echo "== $id baixando $(date +%T)"
  ( cd "$VOX" && python3 baixar_v1.py --url "https://www.youtube.com/watch?v=$id" --outdir "$D/audio" --quality audio ) > "$D/baixar.log" 2>&1 || { echo "falhou download $id"; continue; }
  A=$(ls -S "$D"/audio/*.{wav,m4a,mp3,webm,opus} 2>/dev/null | head -1)
  [ -z "$A" ] && { echo "sem audio $id"; continue; }
  echo "== $id transcrevendo $(date +%T) $A"
  ( cd "$VOX" && python3 transcrever_v1.py --in "$A" --outdir "$D" --whisper-model "$MODELO" --src "$L" ) > "$D/tx.log" 2>&1 \
    && echo whisper > "$D/fonte" || echo "falhou tx $id"
done
echo "fim $(date +%T)"
