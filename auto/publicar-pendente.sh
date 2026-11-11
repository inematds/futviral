#!/usr/bin/env bash
# Substituído pelo Radar Viral em 10/11/2026: a fila única do lives24 (1 por hora) fica em ~/projetos/radar-viral.
# Este atalho publica o próximo vídeo liberado da fila (de qualquer nicho), igual ao timer radar-viral.
exec python3 "$HOME/projetos/radar-viral/radar.py" publicar
