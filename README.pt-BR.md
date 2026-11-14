<div>

[🇺🇸 English](README.md) · [🇧🇷 Português](README.pt-BR.md)

</div>

<div align="center">
  <img
    width="1000"
    alt="codelabs — laboratório pessoal de engenharia"
    src="https://github.com/user-attachments/assets/e253983a-97d3-441f-b587-bcfbf6f4fd7f"
  />
</div>

<br />

<div align="center">

![Commits](https://shieldcn.dev/github/commits/thiagonddev/codelabs.svg?size=default&logo=ri%3AFiGitCommit&mode=dark)
![Último commit](https://shieldcn.dev/github/last-commit/thiagonddev/codelabs.svg?size=default&logo=ri%3AFiGitCommit&mode=dark)

</div>

<br />

# codelabs

<br />

> Um laboratório pessoal de engenharia para experimentação, prototipagem e aprendizado contínuo.

<br />

O _`codelabs`_ reúne experimentos focados na exploração de conceitos de software por meio de implementações práticas.

<br />

O repositório abrange fundamentos de programação, desenvolvimento de _backend_, comportamento de ambientes de execução (_runtimes_), integrações com bancos de dados, testes e ferramentas de desenvolvimento.

<br />

Em vez de priorizar aplicações finalizadas, o objetivo é compreender como o _software_ funciona, por que diferentes implementações se comportam de determinada maneira e quais custos e benefícios cada abordagem apresenta.

<br />

> [!NOTE]
>
> O _`codelabs`_ está em constante evolução.
>
>
> Seu código, dependências, convenções e estrutura podem mudar conforme os experimentos avançam e novas perguntas surgem.

<br />

## Explore

<br />

| Área | O que você encontrará | Documentação |
| --- | --- | --- |
| **Bash** | Exercícios introdutórios sobre variáveis, entrada de dados e execução condicional. | [Guia de _Bash_](languages/bash/README.md) |
| **JavaScript e TypeScript** | Configuração do ambiente, ferramentas de desenvolvimento e fluxo de testes. | [Espaço de _JavaScript_](languages/js/README.md) |
| **Conceitos de Node.js** | APIs nativas, _CommonJS_, servidores HTTP e experimentos com _SQLite_ e _Supabase_. | [Guia de _Node.js_](languages/js/backend/node/README.md) |
| **Express** | Configuração de servidores, CORS, roteamento, integração com _SQLite_ e experimentos de autenticação. | [Guia de _Express_](languages/js/backend/node/frameworks/express/README.md) |
| **Recursos compartilhados** | Módulos reutilizáveis de autenticação, banco de dados e servidor. | [Guia de recursos compartilhados](languages/js/backend/node/shared/README.md) |
| **Testes** | Configuração do _Jest_ e testes HTTP com _Supertest_. | [Guia de testes](languages/js/tests/README.md) |
| **Scripts** | Instalação de dependências e ferramentas para gerar árvores de diretórios. | [Guia de _scripts_](scripts/README.md) |

<br />

## Estrutura

<br />

O repositório é organizado por linguagem e área de desenvolvimento.

<br />

Os experimentos mantêm estruturas independentes, enquanto o código compartilhado é introduzido quando oferece benefícios práticos.

<br />

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

<br />

Esta é uma visão geral, não uma listagem completa de arquivos.

<br />

Cada diretório de experimento contém seus próprios arquivos-fonte, manifestos, arquivos de dependências e recursos de apoio.

<br />

## Primeiros passos

### Requisitos

<br />

- **_Node.js_:** versão `26.13.1` ou superior, conforme declarado nos manifestos dos espaços de JavaScript e Node.js.

<br />

- **npm:** utilizado para instalar as dependências dos experimentos em JavaScript e Node.js.

<br />

- **_Bash_:** necessário para os _scripts_ utilitários e os exemplos de _Bash_.

<br />

- **_tree_:** necessário somente para o _script_ que gera a árvore de diretórios.

<br />

### Instalação de Dependências do _JavaScript_

<br />

Não existe um único projeto npm na raiz do repositório.

<br />

Os manifestos de pacotes estão distribuídos pelo espaço de _JavaScript_ e pelos experimentos individuais.

<br />

Na raiz do repositório, visualize previamente as ações do _script_:

```bash
./scripts/js/setup.sh --dry-run
```

<br />

Em seguida, instale as dependências:

```bash
./scripts/js/setup.sh
```

<br />

O _script_ localiza arquivos `package.json` dentro de `languages/js`, instala as dependências dos pacotes que as declaram, ignora pacotes sem dependências e continua a execução mesmo quando uma instalação individual falha.

<br />

Confira o resumo final para identificar eventuais falhas.

<br />

Consulte o [guia do espaço de _JavaScript_](languages/js/README.md) para entender a organização das dependências, a verificação de tipos e os testes.

<br />

### Executar um exercício de _Bash_

<br />

A partir da raiz do repositório:

```bash
bash languages/bash/intro/variables.sh
bash languages/bash/intro/conditions.sh
```

<br />

--- 

<br />

### Executar os Testes

<br />

Após instalar as dependências:

```bash
cd languages/js
npm test
```

<br />

Também estão disponíveis comandos para modo de observação e cobertura:

```bash
npm run test:watch
npm run test:coverage
```

<br />

Os testes e o resolvedor personalizado do _Jest_ estão documentados no [guia de testes](languages/js/tests/README.md).

<br />

## Experimentos

<br />

Cada experimento parte de uma pergunta, conceito ou detalhe de implementação que merece investigação.

<br />

Dependendo de seu escopo, pode conter código-fonte, manifesto de pacote, configurações, esquemas de banco de dados, exemplos de requisições HTTP ou testes automatizados.

<br />

Os experimentos não precisam compartilhar uma única arquitetura ou camada de abstração. Mantê-los focados facilita a comparação entre abordagens e a compreensão de seu comportamento sem introduzir acoplamento desnecessário.

<br />

Alguns experimentos podem permanecer incompletos ou nunca ultrapassar a etapa de prova de conceito; outros podem ser refatorados ou ampliados conforme a compreensão sobre o assunto evolui.

<br />

**O objetivo principal é compreender, não alcançar prontidão para produção.**

<br />

A menos que um experimento indique explicitamente o contrário, considere seu código um exercício de aprendizado, e não uma implementação pronta para produção.

<br />

## Princípios

<br />

- **Aprender construindo.** Investigar conceitos por meio de implementações pequenas e práticas.

<br />

- **Priorizar a compreensão.** Introduzir abstrações quando elas ajudam a responder à pergunta investigada.

<br />

- **Comparar abordagens.** Examinar como diferentes implementações resolvem problemas semelhantes e quais custos e benefícios apresentam.

<br />

- **Manter o foco.** Permitir que cada exploração evolua conforme seu escopo e suas necessidades.

<br />

- **Preservar descobertas úteis.** Documentar configurações não óbvias, decisões e observações junto ao código relevante.

---

<br />

<div align="center">

> “_Code is the medium; understanding is the outcome_.”

</div>

<br />

---