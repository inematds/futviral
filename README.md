# futviral

[![futviral — radar de futebol](guia/assets/banner.jpg)](https://inematds.github.io/futviral/guia/)

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

## O que é

O futviral faz, sozinho, vídeos curtos (9:16) com o resumo do que os 10 maiores canais de futebol do YouTube disseram: Brasileirão, futebol europeu, mercado da bola, polêmicas e negócios do futebol. Ele assiste aos vídeos por transcrição, separa os números e os fatos com a fonte de cada um e monta um vídeo com números grandes, carimbos (RUMOR, NEGOCIANDO, FECHADO, POLÊMICA) e o Nei comentando (avatar). Rumor é tratado como rumor, nenhum clube tem lado e aposta não entra. Roda num computador com GPU, com a assinatura do Claude Code e do HeyGen. É irmão do [advviral](https://github.com/inematds/advviral), do [saudeviral](https://github.com/inematds/saudeviral) e do [finviral](https://github.com/inematds/finviral) (mesmo motor, outro tema).

## 📖 Guia de uso

Guia completo (landing + passo a passo): **https://inematds.github.io/futviral/guia/**

## Os 10 canais

Escolhidos em 26/10/2026 por medição própria (yt-dlp, mediana de views dos últimos 15 vídeos, canal ativo e falado). Detalhes em [`pesquisa/canais.md`](pesquisa/canais.md); lista viva em `canais.json`.

Eurão · Jovem Pan Esportes · Jozão · Fabrizio Romano · Chico Garcia · Tode · Fred Caldeira · TiaGOL · Canal do Nicola · Mauro Cezar.

## O processo, do início ao fim

| # | Passo | Comando | Quem faz |
|---|---|---|---|
| 1 | Lista os vídeos dos canais do período (só metadados) | `coleta/listar.py` (chamado pelo `auto/rodar.sh`) | ⚙️ script |
| 2 | Escolhe 1 vídeo por canal (o mais visto), sem repetir vídeo já usado | `auto/rodar.sh` + `auto/usados.py` | ⚙️ script |
| 3 | Pega a legenda do YouTube (segundos); se não houver, baixa o áudio e transcreve local (inemavox, Whisper large-v3; inglês para o Fabrizio) | `coleta/transcrever.sh` + `coleta/legenda_yt.py` | ⚙️ script |
| 4 | Escreve `base.md` (fato + trecho literal), `roteiro.json` e `legenda.txt` | `claude -p` com `auto/roteiro.md` | 🤖 `claude -p` |
| 5 | Confere trechos, números por extenso, 5+ assuntos, aviso de rumor, sem aposta; 1 correção | `auto/checar.py` | ⚙️ script |
| 6 | Avatar do Nei no estúdio HeyGen (assinatura); se falhar, foto + voz do Nei | `motor/avatar_heygen.sh` / `motor/narrar.py` | ⚙️ script |
| 7 | Renderiza o vídeo (palco.html quadro a quadro) e compõe o avatar | `motor/gerar_cena.py` + `motor/compor_avatar.sh` | ⚙️ script |
| 8 | Geração às 9h: o vídeo vai ao bot como prévia. Ao meio-dia publica no YouTube **Inema Pro (lives12)** e manda o link ao bot (`touch <edição>/SEGURAR` segura) | `auto/publicar.sh` + `auto/publicar-pendente.sh` (yt-pubx) | ⚙️ timer 09:00 / 12:00 |
| 9 | Sáb/dom: longo 16:9 "A semana explicada" | `auto/roteiro-longo.md` → `auto/longo.sh` | 🤖 + ⚙️ |
| 10 | Aprovar o formato, incluir/tirar canais, ligar a agenda | `canais.json`, `systemd/` | 🧠 sessão com o Nei |

Rodada à mão:

```bash
auto/rodar.sh diario 2026-10-26                 # rodada completa (avatar + lives12 + bot)
SEM_AVATAR=1 auto/rodar.sh diario 2026-10-26    # versão com foto, só para o bot
REUSAR_ROTEIRO=1 auto/rodar.sh diario 2026-10-26  # refaz avatar/vídeo/publicação com o roteiro já aprovado
```

Agenda (`systemd/futviral-*.timer`, ligada em 26/10/2026): geração às 09:00 (diário seg–sex, semanal no sábado, domingo no domingo) e publicação às 12:00.

## Regras de cada vídeo

- Todo fato tem a fonte (canal, data, título) na tela e um trecho literal da transcrição no `base.md`.
- Rumor só vale quando o clube confirma: transferência é "rumor" ou "negociando" até o clube confirmar.
- Sem torcer: tudo é atribuído a quem disse.
- Sem aposta: nada de bet, odd ou palpite. O portão reprova.
- Sem lance, gol, imagem de jogo ou escudo de clube (direito de transmissão).
- Fala no tom do Nei, tratando por "você", com números por extenso. Fim: pergunta para comentar e CTA do inema.club.
- HeyGen só pelo estúdio da assinatura. A oferta de troca de plano é sempre recusada.

## Licença

MIT.
