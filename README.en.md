# futviral

[![futviral — football radar](guia/assets/banner-en.jpg)](https://inematds.github.io/futviral/guia/en/)

**🇧🇷 [Português](README.md) · 🇺🇸 [English](README.en.md) · 🇪🇸 [Español](README.es.md)**

## What it is

futviral makes, on its own, short videos (9:16) summing up what the 10 biggest football channels on YouTube said: Brasileirão, European football, the transfer market, controversies and the business of football. It watches the videos through their transcripts, pulls out the numbers and facts with the source of each one, and builds a video with big numbers, stamps (RUMOR, NEGOCIANDO, FECHADO, POLÊMICA — rumor, negotiating, done deal, controversy) and Nei commenting (avatar). A rumor is treated as a rumor, no club gets a side and betting is left out. It runs on a computer with a GPU, using the Claude Code and HeyGen subscriptions. It is a sibling of [advviral](https://github.com/inematds/advviral), [saudeviral](https://github.com/inematds/saudeviral) and [finviral](https://github.com/inematds/finviral) (same engine, different topic).

## 📖 User guide

Full guide (landing + step by step): **https://inematds.github.io/futviral/guia/en/**

## The 10 channels

Chosen on 10/26/2026 by our own measurement (yt-dlp, median views of the last 15 videos, active channel with spoken content). Details in [`pesquisa/canais.md`](pesquisa/canais.md) (in Portuguese); live list in `canais.json`.

Eurão · Jovem Pan Esportes · Jozão · Fabrizio Romano · Chico Garcia · Tode · Fred Caldeira · TiaGOL · Canal do Nicola · Mauro Cezar.

## The process, start to finish

| # | Step | Command | Who does it |
|---|---|---|---|
| 1 | Lists the channels' videos for the period (metadata only) | `coleta/listar.py` (called by `auto/rodar.sh`) | ⚙️ script |
| 2 | Picks 1 video per channel (the most viewed), never repeating a video already used | `auto/rodar.sh` + `auto/usados.py` | ⚙️ script |
| 3 | Takes the YouTube caption (seconds); if there isn't one, downloads the audio and transcribes locally (inemavox, Whisper large-v3; English for Fabrizio) | `coleta/transcrever.sh` + `coleta/legenda_yt.py` | ⚙️ script |
| 4 | Writes `base.md` (fact + literal excerpt), `roteiro.json` and `legenda.txt` | `claude -p` with `auto/roteiro.md` | 🤖 `claude -p` |
| 5 | Checks excerpts, numbers spelled out, 5+ topics, rumor notice, no betting; 1 correction | `auto/checar.py` | ⚙️ script |
| 6 | Nei's avatar in the HeyGen studio (subscription); if it fails, Nei's photo + voice | `motor/avatar_heygen.sh` / `motor/narrar.py` | ⚙️ script |
| 7 | Renders the video (palco.html frame by frame) and composites the avatar | `motor/gerar_cena.py` + `motor/compor_avatar.sh` | ⚙️ script |
| 8 | Generation at 9 am: the video goes to the bot as a preview. At noon it publishes to YouTube **Inema Club24 (lives24)** and sends the link to the bot (`touch <edition>/SEGURAR` holds it) | `auto/publicar.sh` + `auto/publicar-pendente.sh` (yt-pubx) | ⚙️ timer 09:00 / 12:00 |
| 9 | Sat/Sun: long 16:9 "A semana explicada" (The week explained) | `auto/roteiro-longo.md` → `auto/longo.sh` | 🤖 + ⚙️ |
| 10 | Approve the format, add/remove channels, turn on the schedule | `canais.json`, `systemd/` | 🧠 session with Nei |

Run by hand:

```bash
auto/rodar.sh diario 2026-10-26                 # full run (avatar + lives24 + bot)
SEM_AVATAR=1 auto/rodar.sh diario 2026-10-26    # photo version, bot only
REUSAR_ROTEIRO=1 auto/rodar.sh diario 2026-10-26  # redo avatar/video/publishing with the script already approved
```

Schedule (`systemd/futviral-*.timer`, switched on 10/26/2026): generation at 09:00 (diario Mon–Fri, semanal on Saturday, domingo on Sunday) and publishing at 12:00.

## Rules for every video

- Every fact has its source (channel, date, title) on screen and a literal excerpt from the transcript in `base.md`.
- A rumor only counts when the club confirms it: a transfer is "rumor" or "negociando" (negotiating) until the club confirms it.
- No rooting: everything is attributed to whoever said it.
- No betting: no bets, odds or tips. The gate rejects it.
- No plays, goals, match footage or club crests (broadcast rights).
- Spoken in Nei's tone, addressing the viewer as "você", with numbers spelled out in words. At the end: a question to comment on and the inema.club CTA.
- HeyGen only through the subscription studio. The plan-change offer is always declined.

## License

MIT.
