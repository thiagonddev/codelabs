🇺🇸 [EN](#-codelabs) <br>
🇧🇷 [PT](#-codelabs-1)

<br />

# (🇺🇸) codelabs

<br />

> _A personal monorepo for experiments, prototypes & learning_.

<br />

### Table of Contents

<br />

- [Summary](#summary)
- [Topics](#topics)
- [Structure](#structure)
- [Current Focus](#current-focus)
- [Philosophy](#philosophy)
- [Final Notes](#final-notes)

<br />

## Summary

<br />

**codelabs** is my personal playground for exploring technologies, testing ideas & understanding how software works under the hood.

<br />

Rather than a collection of polished portfolio projects, it is a space for experimentation: a place to compare implementations, explore unfamiliar tools, investigate architectural approaches & learn through hands-on development.

<br />

I think of these experiments as **knowledge drafts** — small, focused explorations designed to answer questions, validate ideas or deepen my understanding of a particular concept or technology.

<br />

Some experiments may eventually evolve into more complete projects. 

<br />

Others exist simply to explore an idea or understand how something works.

<br />

## Topics

<br />

The repository covers different areas of software development, including:

<br />

- Languages & runtimes
- Backend architectures
- Frameworks and libraries
- Database integrations & schema design
- HTTP servers and API design
- Authentication & security
- Project organization and shared infrastructure
- Development workflows & tooling
- Alternative implementations of the same problem

<br />

The objective isn't always to build something production-ready.

<br />

Sometimes, the most valuable outcome is simply understanding a concept or discovering why one approach works better than another.

<br />

## Structure

<br />

The repository is organized by language, runtime & area of experimentation rather than around a single application or architectural pattern.

<br />

```
codelabs/
├── languages/
│   ├── bash/
│   │   └── intro/
│   └── js/
│       └── backend/
│           └── node/
│               ├── concepts/
│               ├── frameworks/
│               ├── shared/
│               ├── package.json
│               └── tsconfig.json
├── .github/
├── .gitignore
├── .vsls.json
├── commands.sh
└── README.md
```

<br />

Each area contains focused experiments & supporting files relevant to the technologies being explored.

<br />

### Node.js

<br />

Node.js experiments are organized into three main areas:

<br />

```
node/
├── concepts/
│   └── commonjs/
├── frameworks/
│   └── express/
│       └── commonjs/
└── shared/
    ├── auth/
    ├── database/
    └── server/
```

#### `concepts/`

Experiments focused on Node.js fundamentals, built-in APIs, runtime behavior & core development concepts.

<br />

Examples include:

<br />

- HTTP servers & routing
- Operating system APIs
- Database access with SQLite & Supabase
- CommonJS module behavior

<br />

#### `frameworks/`

Experiments focused on specific frameworks, integrations & implementation patterns.

Current explorations include Express applications, authentication, database integrations & server configuration.

<br />

#### `shared/`

Reusable code & supporting infrastructure shared across experiments, including:

<br />

- Types & schemas
- Authentication utilities
- Database configuration & integrations
- Server configuration
- Environment variable examples & API request files

<br />

Shared code is kept separate from individual experiments to reduce duplication where reuse makes sense, without forcing every experiment into the same architecture.

<br />

### Experiment Organization

<br />

Individual experiments may contain their own source files, dependencies, configuration, database schemas, API examples & documentation.

Their internal structure is intentionally flexible. Each experiment can use the organization that best fits the concept being explored.

Not every experiment needs the same dependencies, abstractions or architectural conventions.

<br />

## Current Focus

<br />

The repository currently focuses primarily on backend development with **Node.js and TypeScript**.

<br />

Areas of exploration include:

<br />

- HTTP servers, routing & request handling
- Express & middleware
- SQLite & Supabase integrations
- Database schemas & data access
- API structure & design
- CommonJS & Node.js runtime behavior
- Authentication, JWTs & password hashing
- TypeScript configuration & project organization
- Shared infrastructure & reusable modules

<br />

Other languages, frameworks & technologies will be added as my interests and experiments evolve.

<br />

## Philosophy

<br />

The guiding principle behind codelabs is simple: **learn by building.**

<br />

I use this repository to:

<br />

- Explore unfamiliar concepts through practical experiments.
- Compare implementations & architectural approaches.
- Evaluate technologies before adopting them in larger projects.
- Investigate runtime behavior, libraries & development tools.
- Build isolated proofs of concept without unnecessary complexity.
- Document experiments & retain what I learn along the way.

<br />

The code doesn't always need to be elegant, complete or production-ready.

<br />

**It needs to serve its purpose: learning.**

<br />

## Final Notes

<br />

This repository is a work in progress. Its code, dependencies, conventions and directory structures may change as experiments evolve.

<br />

Some experiments may remain incomplete or never progress beyond a proof of concept; others may be refactored, replaced or expanded as my understanding improves.

<br />

That's intentional.

<br />

An experiment doesn't need to become a finished project to be valuable.

<br />

Understanding why an approach works, why it fails or how it compares to an alternative is a worthwhile outcome in itself.

<br />

---

<br />

# (🇧🇷) codelabs

<br />

> _Um monorepo pessoal para experimentação, prototipagem e aprendizado_.

<br />

### Índice

<br />

- [Descrição](#descrição)
- [Tópicos](#tópicos)
- [Estrutura](#estrutura)
- [Foco Atual](#foco-atual)
- [Filosofia](#filosofia)
- [Observações Finais](#observações-finais)

<br />

## Descrição

<br />

**_codelabs_** é meu espaço pessoal para explorar tecnologias, testar ideias e entender como o software funciona por baixo dos panos.

<br />

Em vez de ser uma coleção de projetos de portfólio finalizados, é um ambiente de experimentação: um lugar para comparar implementações, explorar ferramentas desconhecidas, investigar abordagens arquiteturais e aprender na prática.

<br />

Encaro esses experimentos como **rascunhos de conhecimento** (_knowledge drafts_) — explorações pequenas e focadas, criadas para responder perguntas, validar ideias ou aprofundar meu entendimento sobre determinado conceito ou tecnologia.

<br />

Alguns experimentos podem evoluir para projetos mais completos. 

<br />

Outros existem simplesmente para explorar uma ideia ou entender como algo funciona.

<br />

## Tópicos

<br />

O repositório abrange diferentes áreas do desenvolvimento de _software_, incluindo:

<br />

- Linguagens e ambientes de execução (_runtimes_)
- Arquiteturas de _backend_
- _Frameworks_ e bibliotecas
- Integrações com bancos de dados e modelagem de esquemas
- Servidores HTTP e _design_ de APIs
- Autenticação e segurança
- Organização de projetos e infraestrutura compartilhada
- Fluxos de desenvolvimento e ferramentas
- Diferentes implementações para um mesmo problema

<br />

O objetivo nem sempre é construir algo pronto para produção.

<br />

Às vezes, o resultado mais valioso é simplesmente compreender um conceito ou descobrir por que determinada abordagem funciona melhor do que outra.

<br />

## Estrutura

<br />

O repositório é organizado por linguagem, _runtime_ e área de experimentação, em vez de seguir a estrutura de uma única aplicação ou um padrão arquitetural específico.

<br />

```
codelabs/
├── languages/
│   ├── bash/
│   │   └── intro/
│   └── js/
│       └── backend/
│           └── node/
│               ├── concepts/
│               ├── frameworks/
│               ├── shared/
│               ├── package.json
│               └── tsconfig.json
├── .github/
├── .gitignore
├── .vsls.json
├── commands.sh
└── README.md
```

<br />

Cada área reúne experimentos independentes e arquivos de apoio relacionados às tecnologias exploradas.

<br />

### _Node.js_

<br />

Os experimentos com _Node.js_ são organizados em três áreas principais:

<br />

```
node/
├── concepts/
│   └── commonjs/
├── frameworks/
│   └── express/
│       └── commonjs/
└── shared/
    ├── auth/
    ├── database/
    └── server/
```

#### `concepts/`

<br />

Experimentos voltados aos fundamentos do _Node.js_, às APIs nativas, ao comportamento do _runtime_ e a conceitos essenciais do desenvolvimento.

<br />

Ex.:

- Servidores HTTP e roteamento
- APIs do sistema operacional
- Acesso a bancos de dados com _SQLite_ e _Supabase_
- Funcionamento dos módulos _CommonJS_

<br />

#### `frameworks/`

<br />

Experimentos voltados a frameworks específicos, integrações e padrões de implementação.

As explorações atuais incluem aplicações _Express_, autenticação, integrações com bancos de dados e configuração de servidores.

<br />

#### `shared/`

<br />

Código reutilizável e infraestrutura de apoio compartilhados entre experimentos, incluindo:

<br />

- Tipos e esquemas
- Utilitários de autenticação
- Configurações e integrações com bancos de dados
- Configurações de servidores
- Exemplos de variáveis de ambiente e arquivos de requisições HTTP

<br />

O código compartilhado fica separado dos experimentos individuais para reduzir duplicações quando o reaproveitamento faz sentido, sem obrigar todos os experimentos a seguir a mesma arquitetura.

<br />

### Organização dos Experimentos

<br />

Cada experimento pode conter seus próprios arquivos-fonte, dependências, configurações, esquemas de banco de dados, exemplos de requisições HTTP e documentação.

A estrutura interna é intencionalmente flexível. Cada experimento pode adotar a organização que melhor se adequa ao conceito explorado.

Nem todos precisam das mesmas dependências, abstrações ou convenções arquiteturais.

<br />

## Foco Atual

<br />

Atualmente, o repositório se concentra principalmente no desenvolvimento de backend com **_Node.js_ e _TypeScript_**.

<br />

As áreas de exploração incluem:

<br />

- Servidores HTTP, roteamento e tratamento de requisições
- _Express_ e _middlewares_
- Integrações com _SQLite_ e _Supabase_
- Esquemas de banco de dados e acesso a dados
- Estrutura e design de APIs
- _CommonJS_ e comportamento do _runtime_ do _Node.js_
- Autenticação, JWTs e _hashing_ de senhas
- Configuração do _TypeScript_ e organização de projetos
- Infraestrutura compartilhada e módulos reutilizáveis

<br />

Outras linguagens, _frameworks_ e tecnologias serão adicionados conforme meus interesses e experimentos evoluírem.

<br />

## Filosofia

<br />

O princípio que orienta o _codelabs_ é simples: **aprender construindo.**

<br />

Uso este repositório para:

<br />

- Explorar conceitos desconhecidos por meio de experimentos práticos.
- Comparar implementações e abordagens arquiteturais.
- Avaliar tecnologias antes de adotá-las em projetos maiores.
- Investigar o comportamento do _runtime_, bibliotecas e ferramentas de desenvolvimento.
- Criar provas de conceito isoladas sem complexidade desnecessária.
- Registrar experimentos e preservar o conhecimento adquirido ao longo do processo.

<br />

O código nem sempre precisa ser elegante, completo ou estar pronto para produção.

<br />

**Ele precisa cumprir seu propósito: ensinar.**

<br />

## Observações Finais

<br />

Este repositório está em constante evolução. O código, as dependências, as convenções e as estruturas de diretórios podem mudar conforme os experimentos avançam.

<br />

Alguns experimentos podem permanecer incompletos ou nunca ultrapassar a etapa de prova de conceito; outros podem ser refatorados, substituídos ou expandidos à medida que meu entendimento evolui.

<br />

Isso é intencional.

<br />

Um experimento não precisa se tornar um projeto finalizado para ter valor.

<br />

Entender por que uma abordagem funciona, por que falha ou como se compara a uma alternativa já é, por si só, um resultado válido.

<br />

---

<br />

> _codelabs is about exploration, not perfection._
