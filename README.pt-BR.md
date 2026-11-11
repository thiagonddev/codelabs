# codelabs

<div align="center">
  <img
    width="1000"
    alt="codelabs — laboratório pessoal de engenharia"
    src="https://github.com/user-attachments/assets/e253983a-97d3-441f-b587-bcfbf6f4fd7f"
  />
</div>

<div align="center">

![Commits](https://shieldcn.dev/github/commits/thiagonddev/codelabs.svg?size=default&logo=ri%3AFiGitCommit&mode=dark)
![Último commit](https://shieldcn.dev/github/last-commit/thiagonddev/codelabs.svg?size=default&logo=ri%3AFiGitCommit&mode=dark)

</div>

<div align="center">

[🇺🇸 English](README.md) · [🇧🇷 Português](README.pt-BR.md)

</div>

> Um laboratório pessoal de engenharia para experimentação, prototipagem e aprendizado contínuo.

O `codelabs` reúne experimentos focados na exploração de conceitos de software por meio de implementações práticas. O repositório abrange fundamentos de programação, desenvolvimento de backend, comportamento de ambientes de execução (_runtimes_), integrações com bancos de dados, testes e ferramentas de desenvolvimento.

Em vez de priorizar aplicações finalizadas, o objetivo é compreender como o software funciona, por que diferentes implementações se comportam de determinada maneira e quais custos e benefícios cada abordagem apresenta.

## Explore

| Área | O que você encontrará | Documentação |
| --- | --- | --- |
| **Bash** | Exercícios introdutórios sobre variáveis, entrada de dados e execução condicional. | [Guia de Bash](languages/bash/README.md) |
| **JavaScript e TypeScript** | Configuração do ambiente, ferramentas de desenvolvimento e fluxo de testes. | [Espaço de JavaScript](languages/js/README.md) |
| **Conceitos de Node.js** | APIs nativas, CommonJS, servidores HTTP e experimentos com SQLite e Supabase. | [Guia de Node.js](languages/js/backend/node/README.md) |
| **Express** | Configuração de servidores, CORS, roteamento, integração com SQLite e experimentos de autenticação. | [Guia de Express](languages/js/backend/node/frameworks/express/README.md) |
| **Recursos compartilhados** | Módulos reutilizáveis de autenticação, banco de dados e servidor. | [Guia de recursos compartilhados](languages/js/backend/node/shared/README.md) |
| **Testes** | Configuração do Jest e testes HTTP com Supertest. | [Guia de testes](languages/js/tests/README.md) |
| **Scripts** | Instalação de dependências e ferramentas para gerar árvores de diretórios. | [Guia de scripts](scripts/README.md) |

## Estrutura do repositório

O repositório é organizado por linguagem e área de desenvolvimento. Os experimentos mantêm estruturas independentes, enquanto o código compartilhado é introduzido quando oferece benefícios práticos.

```text
codelabs/
├── languages/
│   ├── bash/
│   │   ├── README.md
│   │   └── intro/
│   └── js/
│       ├── README.md
│       ├── backend/
│       │   └── node/
│       │       ├── README.md
│       │       ├── concepts/
│       │       ├── frameworks/
│       │       │   └── express/
│       │       └── shared/
│       └── tests/
│           └── README.md
├── scripts/
│   └── README.md
├── README.md
└── README.pt-BR.md
```

Esta é uma visão geral, não uma listagem completa de arquivos. Cada diretório de experimento contém seus próprios arquivos-fonte, manifestos, arquivos de dependências e recursos de apoio.

## Primeiros passos

### Requisitos

- **Node.js:** versão `24.22.1` ou superior, conforme declarado nos manifestos dos espaços de JavaScript e Node.js.
- **npm:** utilizado para instalar as dependências dos experimentos em JavaScript e Node.js.
- **Bash:** necessário para os scripts utilitários e os exemplos de Bash.
- **tree:** necessário somente para o script que gera a árvore de diretórios.

### Instalar as dependências de JavaScript

Não existe um único projeto npm na raiz do repositório. Os manifestos de pacotes estão distribuídos pelo espaço de JavaScript e pelos experimentos individuais.

Na raiz do repositório, visualize previamente as ações do script:

```bash
./scripts/js/setup.sh --dry-run
```

Em seguida, instale as dependências:

```bash
./scripts/js/setup.sh
```

O script localiza arquivos `package.json` dentro de `languages/js`, instala as dependências dos pacotes que as declaram, ignora pacotes sem dependências e continua a execução mesmo quando uma instalação individual falha. Confira o resumo final para identificar eventuais falhas.

Consulte o [guia do espaço de JavaScript](languages/js/README.md) para entender a organização das dependências, a verificação de tipos e os testes.

### Executar um exercício de Bash

A partir da raiz do repositório:

```bash
bash languages/bash/intro/variables.sh
bash languages/bash/intro/conditions.sh
```

### Executar os testes

Após instalar as dependências:

```bash
cd languages/js
npm test
```

Também estão disponíveis comandos para modo de observação e cobertura:

```bash
npm run test:watch
npm run test:coverage
```

Os testes e o resolvedor personalizado do Jest estão documentados no [guia de testes](languages/js/tests/README.md).

## Sobre os experimentos

Cada experimento parte de uma pergunta, conceito ou detalhe de implementação que merece investigação. Dependendo de seu escopo, pode conter código-fonte, manifesto de pacote, configurações, esquemas de banco de dados, exemplos de requisições HTTP ou testes automatizados.

Os experimentos não precisam compartilhar uma única arquitetura ou camada de abstração. Mantê-los focados facilita a comparação entre abordagens e a compreensão de seu comportamento sem introduzir acoplamento desnecessário.

Alguns experimentos podem permanecer incompletos ou nunca ultrapassar a etapa de prova de conceito. Outros podem ser refatorados ou ampliados conforme a compreensão sobre o assunto evolui.

**O objetivo principal é compreender, não alcançar prontidão para produção.** A menos que um experimento indique explicitamente o contrário, considere seu código um exercício de aprendizado, e não uma implementação pronta para produção.

## Princípios do projeto

- **Aprender construindo.** Investigar conceitos por meio de implementações pequenas e práticas.
- **Priorizar a compreensão.** Introduzir abstrações quando elas ajudam a responder à pergunta investigada.
- **Comparar abordagens.** Examinar como diferentes implementações resolvem problemas semelhantes e quais custos e benefícios apresentam.
- **Manter o foco.** Permitir que cada exploração evolua conforme seu escopo e suas necessidades.
- **Preservar descobertas úteis.** Documentar configurações não óbvias, decisões e observações junto ao código relevante.

---

O `codelabs` está em constante evolução. Seu código, dependências, convenções e estrutura podem mudar conforme os experimentos avançam e novas perguntas surgem.
