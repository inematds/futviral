| data | o que quebrou | menor correção | prompt \| infra |
|---|---|---|---|
| 2026-11-28 | curto reprovado por passar de 420 palavras em 22 e 27/11, sem vídeo no dia: 19 falas × ~23 palavras não cabem em 400, e a correção só dizia "passou" | pedido de 280 a 350 palavras e até 18 por fala; ao estourar, a correção mostra as falas mais longas e tira o último assunto (aceita 4) | prompt |
| 2026-10-27 | refazer a edição com o mesmo título deixou o estúdio do HeyGen preso no rascunho antigo ("continuando dele" → waitForURL 60 s) e caiu na versão com foto | refação usa título novo (`…-v2`); avatar_heygen.sh deveria recusar rascunho de roteiro diferente | infra |
| 2026-10-26 | passada com avatar (REUSAR_ROTEIRO) escolheu outros vídeos porque a versão com foto marcou os 10 como usados; a correção automática reescreveu o roteiro com notícia velha | teste com foto não registra usados; REUSAR reaproveita o videos.tsv; SEGURAR segura publicação imediata | prompt + infra |
