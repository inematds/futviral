#!/usr/bin/env bash
# Publica no lives24 os vídeos que a geração das 9h deixou pendentes (<ed>/PUBLICAR_PENDENTE.<video>).
# Timer das 12:00 (Nei, 26/10/2026). <ed>/SEGURAR impede a publicação daquela edição (avisa no bot).
# uso: auto/publicar-pendente.sh            (todas as pendentes dos últimos 2 dias)
set -uo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
BOT="$HOME/projetos/refazvideo/ferramentas/enviar_bot_v3.mjs"
# placar da máquina (~/projetos/wifi/scripts/rodada, 09/11/2026): início e fim desta rodada; sem o comando (VPS6) não faz nada.
# publicado só com URL do YouTube de verdade; RODADA_UNIDADE=teste-... nos ensaios; o trap grava "falhou" em saída inesperada.
RODADA="$HOME/projetos/wifi/scripts/rodada"; UNIDADE="${RODADA_UNIDADE:-$(basename "$RAIZ")-publicar}"; EDN="$(date +%F)"; FIM_GRAVADO=""
placar() { if [ -x "$RODADA" ]; then "$RODADA" "$@" || true; fi; }
fim() { FIM_GRAVADO=1; placar fim "$UNIDADE" "$1" --edicao "$EDN" "${@:2}"; }
trap 'rc=$?; [ -z "$FIM_GRAVADO" ] && placar fim "$UNIDADE" falhou --edicao "$EDN" --motivo "saída inesperada (código $rc)"' EXIT
placar inicio "$UNIDADE" "$EDN"
exec 9>"$RAIZ/auto/.publicando"; flock -n 9 || { echo "já publicando"; fim ocupado --motivo "outra publicação em andamento"; exit 0; }
n=0; NPUB=0; URL=""; OK_EDS=""; NAO_EDS=""; SEG_EDS=""
for P in $(find "$RAIZ/edicoes" -maxdepth 2 -name 'PUBLICAR_PENDENTE.*' -mtime -2 | sort); do
  E="$(dirname "$P")"
  if [ -e "$E/SEGURAR" ]; then
    SEG_EDS="$SEG_EDS $(basename "$E")"
    echo "segurado: $E"; mv "$P" "$P.segurado"
    echo "futviral: $(basename "$E") segurado (SEGURAR), não foi ao ar" > "$E/aviso-segurado.txt"
    node "$BOT" "$E/aviso-segurado.txt" "futviral · $(basename "$E") · segurado, não publicado" || true
    continue
  fi
  V=$(sed -n 1p "$P"); ROT=$(sed -n 2p "$P"); EXTRA=$(sed -n '3,$p' "$P")
  [ -s "$V" ] || { echo "sem vídeo: $V"; continue; }
  echo "publicando $V"
  # saída capturada e repetida (o stderr aqui é o journal: tee /dev/stderr não abre socket)
  PUB=$(PUBLICANDO_PENDENTE=1 bash "$RAIZ/auto/publicar.sh" "$V" "$E" "$ROT" "$EXTRA"); RC=$?; printf '%s\n' "$PUB"
  [ "$RC" = 0 ] && mv "$P" "$P.feito"
  U=$(printf '%s\n' "$PUB" | grep -o 'https://www.youtube.com/watch?v=[A-Za-z0-9_-]*\|https://youtu.be/[A-Za-z0-9_-]*' | tail -1)
  if [ -n "$U" ]; then URL="$U"; NPUB=$((NPUB+1)); OK_EDS="$OK_EDS $(basename "$E")"; else NAO_EDS="$NAO_EDS $(basename "$E")"; fi
  n=$((n+1))
done
echo "$n publicados $(date '+%F %T')"
# placar: falhou se alguma pendente não ganhou URL; publicado com a última URL; nada pendente = sem_pauta
if [ -n "$NAO_EDS" ]; then fim falhou ${URL:+--url "$URL"} --motivo "não publicou:$NAO_EDS (publicadas: $NPUB)"
elif [ "$NPUB" -gt 0 ]; then fim publicado --url "$URL" --motivo "$NPUB publicada(s):$OK_EDS"
else fim sem_pauta --motivo "nada pendente para publicar${SEG_EDS:+ (segurado:$SEG_EDS)}"; fi
