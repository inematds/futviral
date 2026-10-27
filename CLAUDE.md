# CLAUDE.md — futviral

Conta/autor: `inematds <inematds@gmail.com>`, repo `inematds/futviral`. Fluxo e agenda: README.md. Base de cada edição: `edicoes/<ed>/base.md`. Projetos irmãos (mesmo motor): `~/projetos/advviral` (de onde foi clonado), `~/projetos/saudeviral` e `~/projetos/finviral`.

- Criado em 26/10/2026 a pedido do Nei: radar de futebol "usando o finviral", com os 10 maiores canais de futebol do YouTube medidos por yt-dlp (`pesquisa/canais.md`). "Fecha com esses 10, pode clonar o futviral e publique no lives12."
- Canal: **Inema Pro (lives12)**, por `auto/publicar.sh` (yt-pubx), e SEMPRE ao bot v3 com o link. A versão com foto (avatar falhou ou teste `SEM_AVATAR=1`) só vai ao bot.
- Influenciadores em `canais.json` (só YouTube; `lang: en` para o Fabrizio Romano, o Whisper transcreve em inglês). O Nei inclui/exclui. Eu posso SUGERIR canal consolidado de futebol (nunca emergente, nunca de aposta); só entra com ok dele.
- Regras de futebol (no roteiro e no `checar.py`): todo fato tem trecho literal no base.md; tudo atribuído; rumor é rumor até o clube confirmar; sem torcer por clube; sem aposta (o portão reprova bet/odd/palpite); sem lance, gol ou escudo (direito de transmissão); "Rumor só vale quando o clube confirma." obrigatório.
- Agenda (systemd usuário, `systemd/`): ainda NÃO ligada. Horário a definir com o Nei (finviral 02:00, saudeviral 05:00, advviral 08:00 já usam GPU/HeyGen).
- Avatar: HeyGen pelo ESTÚDIO (assinatura, `motor/avatar_heygen.sh`, trava compartilhada). Títulos `FUTVIRAL-…`. Oferta de troca de plano do HeyGen: SEMPRE recusar.
- Referência de formato: `edicoes/referencia/` é de um projeto irmão; trocar por uma edição do futviral aprovada pelo Nei.

## Self-learning

When I correct you, or you catch yourself making a mistake: before continuing, add the lesson as a one-line rule under ## Lessons, so it never happens again.

## Lessons

- (Herdadas do advviral/finviral, mesmo motor.) Tratar por "você"; CTA só inema.club; números por extenso na fala; âncora `em` em palavra comum; citação literal do transcript; cadeia longa por `systemd-run --user`; não editar .sh com rodada em execução; voz do HeyGen mixada a -14 LUFS.
