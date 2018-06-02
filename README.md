# bando-doura

[![Gem](https://img.shields.io/gem/v/discordrb.svg)](https://rubygems.org/gems/discordrb)

Replica a toda mensagem em um canal de texto com um xingamento aleatório. Escrito com [discordrb](https://github.com/meew0/discordrb). Convide o Bando Doura a sua guilda [aqui](https://discordapp.com/oauth2/authorize?&client_id=451873038313717760&scope=bot).

## Comandos

| Comandos  | Descrição                         | Uso               |
|-----------|-----------------------------------|-------------------|
| `add`     | Adiciona uma frase ao dicionário   .                                         | `-add Nova frase`                   |
| `say`     | **[OWNER ONLY]** Manda uma mensagem.                                         | `-say Alguma coisa`                 |
| `ping`    | Checa o ping do bot, em milisegundos.                                        | `-ping`                             |
| `source`  | Manda o link pro repositório do Bot.                                         | `-source`                           |
| `prefix`  | Mostra ou muda o prefixo utilizado no servidor ou no canal de texto privado. | `-prefix` ou `-prefix Novo prefixo` |
| `invite`  | Manda o link para convidar o Bot a um servidor.                              | `-invite`                           |
| `restart` | **[OWNER ONLY]** Reinicia o Bot.                                             | `-restart`                          |
| `quit`    | **[OWNER ONLY]** Desliga o Bot.                                              | `-quit`                             |

## Instalando

Para utilizar o bot localmente, será necessário as seguintes dependências:

+ Ruby 2.1 ou mais recente
+ Gems `discordrb`, `json` e, opcionalmente para shells em Bash, `rb-readline`.
  + Recomenda-se o uso do [bundler](https://bundler.io/) para a instalação das gems. Um arquivo `Gemfile` vem incluído no repositório.

Caso tenha acesso à uma shell em Bash, dois scripts, `run.sh` e `push.sh` estão incluídos.

O primeiro script irá rodar o bot utilizando o bundler dentro de um loop, saindo dele se o *exit status* for diferente de zero.

O segundo é uma utilidade para forks do GitHub desse repositório, executando, dentre outros comandos, `git push -m "Version bump"`.

Há, também, uma ferramenta opcional de *debugging* do bot, disponível ao instalar a gem `rb-readline`: uma shell interactiva para commandos em Ruby, incluíndo métodos customizados (ver [shell_commands.rb](https://github.com/GnomoP/bando-doura/blob/master/shell_commands.rb)) e acesso ao bot e suas configurações.

Em caso de dúvida quanto o uso do bot localmente, entre em [contato](https://github.com/GnomoP/bando-doura#contato) comigo.

## TODO

+ [ ] Documentação apropriada.
+ [ ] Atualizações automáticas das gems.
+ [ ] Execução de comandos por menções ao bot.
+ [ ] Auto-formatação das frases adicionadas pelo comando `add`.

## Licensa

Este produto é protegido pela licensa GNU General Public License, versão 3, e sua distribuição é permitida sob as condições impostas por sua licensa. Para mais informações, ver [LICENSE](https://github.com/GnomoP/bando-doura/blob/master/LICENSE) (em inglês).

## Contato

+ Email: [ks1202@pm.me](mailto:ks1202@pm.me)
+ Discord: `GnomoP#3142`