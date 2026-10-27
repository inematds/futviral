#!/usr/bin/env python3
"""Legenda do YouTube (json3, baixada pelo yt-dlp) → transcript.txt no mesmo formato que o Whisper grava.
uso: coleta/legenda_yt.py <arquivo.json3> <saida/transcript.txt>
Junta os segmentos em frases de ~20 palavras (a legenda automática não tem pontuação). Sai 1 se vier vazia."""
import json, re, sys

ev = json.load(open(sys.argv[1])).get("events", [])
palavras = []
for e in ev:
    for s in e.get("segs") or []:
        t = s.get("utf8", "").replace("\n", " ")
        if t.strip() and not re.fullmatch(r"\s*\[[^\]]*\]\s*", t):  # tira [Música], [Aplausos]
            palavras += t.split()
if len(palavras) < 30:
    sys.exit(f"legenda curta demais ({len(palavras)} palavras)")
linhas = [" ".join(palavras[i:i + 20]) for i in range(0, len(palavras), 20)]
open(sys.argv[2], "w").write("\n".join(linhas) + "\n")
print(f"{len(palavras)} palavras")
