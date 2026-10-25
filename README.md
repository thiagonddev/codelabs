🇺🇸 **English** · [🇧🇷 Português](#-codelabs-1)

<br />

# 🇺🇸 codelabs

<br />

> *A personal monorepo for experimentation, prototyping & continuous learning.*

<br />

`codelabs` is my personal workspace for exploring technologies, testing ideas & understanding how software works under the hood.

<br />

Rather than a collection of polished portfolio projects, this repository serves as a **hands-on laboratory for learning through implementation**. 

Each experiment investigates a concept, explores a technology, tests an approach or compares different solutions to a problem.

<br />

These experiments are **knowledge drafts**: small, focused explorations that prioritize understanding over completeness.

<br />

Some may evolve into more substantial applications; others may remain isolated proofs of concept.

Both outcomes are valuable.

<br />

> [!NOTE]
> The repository is intentionally exploratory.
> 
> Its purpose is not to make every example production-ready, but to document the process of learning, preserve useful knowledge & provide a foundation for future experiments.

<br />

## Table of Contents

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

The repository is organized by programming language, development domain & area of experimentation rather than around a single application or architectural pattern.

<br />

Its current structure includes:

<br />

- **Bash:** introductory examples covering variables & conditional execution.
- **JavaScript / Node.js:** backend experiments involving runtime fundamentals, CommonJS, HTTP servers and database integrations.
- **Express:** framework-based implementations covering routing, CORS, database access & authentication.
- **Shared resources:** reusable types, database schemas, server configuration and HTTP request collections.
- **Testing:** Jest configuration & Supertest-based backend tests.
- **Tooling:** TypeScript configuration and a shell script for generating a file tree.

<br />

The organization allows experiments to remain independent while supporting shared code where reuse provides a practical benefit.

<br />

## Topics

<br />

The repository explores different aspects of software development, including:

<br />

- Programming languages, runtimes & built-in APIs.
- Backend development and server-side architectures.
- HTTP servers, routing, middleware & API design.
- Frameworks, libraries and native integrations.
- Database schemas, persistence & data access.
- SQLite and Supabase integrations.
- Authentication, JWTs & password hashing.
- JavaScript module systems and TypeScript configuration.
- Shared modules, dependency organization & project structure.
- Automated testing and development tooling.
- Alternative implementations of similar problems.
- Shell scripting & command-line fundamentals.

<br />

These topics represent areas of investigation rather than a fixed roadmap.

<br />

New experiments may introduce other languages, frameworks & tools as new questions arise.

<br />

## Structure

<br />

The repository's top-level organization separates experiments by language & development domain.

<br />

```
codelabs/
├── languages/
│   ├── bash/
│   │   └── intro/
│   │       ├── conditions.sh
│   │       └── variables.sh
│   └── js/
│       ├── backend/
│       │   └── node/
│       │       ├── README.md
│       │       ├── concepts/
│       │       ├── frameworks/
│       │       └── shared/
│       ├── tests/
│       │   └── jest/
│       │       └── backend/
│       │           └── supertest/
│       ├── jest.config.ts
│       └── tsconfig.json
├── scripts/
│   └── filetree.sh
└── README.md
```

<br />

The tree above highlights the main entry points.

<br />

Individual experiment directories contain their own implementations, configuration & supporting resources.

<br />

### Bash

<br />

**Location:** [`languages/bash/`](https://github.com/thiagonddev/codelabs/tree/master/languages/bash/)

<br />

Introductory shell scripting experiments covering:

<br />

- `variables.sh` — variable fundamentals.
- `conditions.sh` — conditional execution.

<br />

These examples provide a foundation for exploring shell syntax, scripting practices and command-line automation.

<br />

### JavaScript & Node.js

<br />

**Location:** [`languages/js/backend/node/`](https://github.com/thiagonddev/codelabs/tree/master/languages/js/backend/node)

<br />

The Node.js workspace focuses on backend development with JavaScript & TypeScript.

Its structure separates lower-level runtime experiments from framework-specific implementations and shared resources.

<br />

#### `concepts/`

<br />

Explorations of Node.js fundamentals & built-in capabilities, organized under `concepts/commonjs/`.

<br />

Current areas include:

<br />

- **Database access:** native SQLite & Supabase integrations.
- **Operating system APIs:** experiments using the Node.js `os` module.
- **HTTP servers:** basic server implementations & route handling.
- **CommonJS:** module organization and runtime-level concepts.

<br />

These experiments help isolate underlying mechanisms from framework abstractions, making their behavior & trade-offs easier to understand.

<br />

#### `frameworks/`

<br />

Framework-oriented implementations currently focus on Express with CommonJS.

<br />

The directory contains experiments covering:

<br />

- **Server fundamentals:** basic applications & server entry points.
- **HTTP behavior:** routing and CORS configuration.
- **Database integration:** native SQLite implementations.
- **Authentication:** JWT-based flows, bcrypt password hashing & SQLite-backed authentication.

<br />

Separating framework implementations from runtime concepts makes it easier to compare higher-level abstractions with lower-level approaches.

<br />

#### `shared/`

<br />

**Location:** [`languages/js/backend/node/shared/`](https://github.com/thiagonddev/codelabs/tree/master/languages/js/backend/node/shared)

<br />

Reusable resources for related experiments, including:

<br />

- Authentication types & database schemas.
- SQLite schemas and Supabase database integration.
- Shared database types.
- Server configuration.
- HTTP request collections for manual API exploration.

<br />

Shared resources are introduced when they help maintain consistency or reduce meaningful duplication.

<br />

They are not mandatory dependencies for every experiment.

<br />

### Testing

<br />

**Location:** [`languages/js/tests/`](https://github.com/thiagonddev/codelabs/tree/master/languages/js/tests)

<br />

The testing workspace contains Jest backend tests built with Supertest.

<br />

Current tests cover Express implementations involving:

<br />

- Basic server behavior.
- HTTP route handling.
- Native SQLite database integration.

<br />

The testing structure provides a dedicated space for exploring endpoint verification, integration testing & automated validation of server behavior.

<br />

The Jest configuration is located at `languages/js/jest.config.ts`, alongside the TypeScript configuration at `languages/js/tsconfig.json`.

<br />

### Scripts & Tooling

<br />

**Location:** [`scripts/`](https://github.com/thiagonddev/codelabs/tree/master/scripts)

<br />

The `filetree.sh` script supports repository inspection by generating a directory-tree representation.

<br />

This small utility complements the repository's exploratory workflow by making its organization easier to inspect & document.

<br />

### Experiment Organization

<br />

Individual experiments may contain source files, database schemas, HTTP request examples, tests & other supporting resources, depending on their scope.

<br />

Their internal structures remain deliberately flexible.

<br />

**Ex.:**

<br />

> A small runtime demonstration may require only one source file, while an API experiment may involve application & server entry points, routing, database access, environment configuration and automated tests.

<br />

Dependencies & configuration can be scoped to individual experiments when necessary.

<br />

This preserves their independence and makes alternative implementations easier to compare without introducing unnecessary coupling.

<br />

## Current Focus

<br />

The primary focus is **backend development with Node.js and TypeScript**, with an emphasis on understanding both the fundamentals of server-side development & the abstractions provided by frameworks.

<br />

Current areas of exploration include:

<br />

- Node.js runtime behavior, built-in APIs & CommonJS.
- HTTP servers, request handling and routing.
- Express applications, middleware & CORS.
- Native SQLite and Supabase integrations.
- Database schemas, persistence and data access.
- JWT-based authentication & bcrypt password hashing.
- TypeScript types, declarations and compiler configuration.
- Shared modules & dependency organization.
- Automated testing with Jest and Supertest.
- Bash variables & conditional execution.

<br />

These areas reflect the current contents of the repository, not a permanent scope.

<br />

The focus may evolve as existing experiments develop & new learning objectives emerge.

<br />

## Philosophy

<br />

The guiding principle behind `codelabs` is simple: **learn by building.**

<br />

I use this repository to:

<br />

- Explore unfamiliar concepts through practical implementations.
- Break complex systems into smaller, understandable experiments.
- Compare alternative solutions & architectural approaches.
- Investigate runtime behavior, APIs, dependencies and tooling.
- Understand the trade-offs between simplicity, abstraction, maintainability & flexibility.
- Test ideas in isolation before introducing them into larger projects.
- Preserve useful findings for future reference.

<br />

Each experiment should have a learning objective, even when that objective is simply answering a question or observing how a mechanism behaves.

<br />

The code does not always need to be elegant, complete or production-ready.

Some experiments prioritize simplicity; others deliberately investigate a particular design decision or expose limitations in an initial approach.

<br />

> **The primary goal is understanding.**

<br />

## Final Notes

<br />

`codelabs` is a work in progress.

<br />

Its code, dependencies, conventions, documentation & directory structure may change as experiments evolve and my understanding improves.

Some explorations may remain incomplete or never progress beyond a proof of concept; others may be refactored, replaced, combined or expanded into more substantial implementations.

<br />

That is intentional.

<br />

Not every experiment needs to become a finished application & not every implementation needs to be reusable.

The scope of each experiment is determined by the question it aims to answer.

<br />

Understanding why an approach works, why it fails, what trade-offs it introduces or how it compares with an alternative is a worthwhile outcome in itself.

<br />

---

<br />


🇧🇷 **Português** · [🇺🇸 English](#-codelabs)

<br />

# 🇧🇷 codelabs

<br />

> *Um monorepo pessoal para experimentação, prototipagem e aprendizado contínuo.*

<br />

O _`codelabs`_ é meu espaço pessoal para explorar tecnologias, testar ideias e compreender como o _software_ funciona por baixo dos panos.

<br />

Em vez de reunir apenas projetos de portfólio finalizados, este repositório funciona como um **laboratório prático de aprendizado por meio da implementação**. 

Cada experimento investiga um conceito, explora uma tecnologia, testa uma abordagem ou compara diferentes soluções para um problema.

<br />

Esses experimentos são **rascunhos de conhecimento** (_knowledge drafts_): explorações pequenas e focadas que priorizam a compreensão em vez da completude. 

<br />

Alguns podem evoluir para aplicações mais elaboradas; outros podem permanecer como provas de conceito isoladas.

Ambos os resultados são válidos.

<br />

> [!NOTE]
> O repositório é intencionalmente exploratório.
>
> Seu objetivo não é tornar todos os exemplos prontos para produção, mas documentar o processo de aprendizado, preservar conhecimentos úteis e fornecer uma base para experimentações futuras.

<br />

## Índice

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

O repositório é organizado por linguagem de programação, domínio de desenvolvimento e área de experimentação, em vez de seguir a estrutura de uma única aplicação ou padrão arquitetural.

<br />

Sua estrutura atual inclui:

<br />

- **_Bash_:** exemplos introdutórios sobre variáveis e execução condicional.

<br />

- **_JavaScript_ / _Node.js_:** experimentos de _backend_ envolvendo fundamentos do ambiente de execução (_runtime_), _CommonJS_, servidores HTTP e integrações com bancos de dados.

<br />

- **_Express_:** implementações baseadas em _framework_ envolvendo roteamento, CORS, acesso a dados e autenticação.

<br />

- **Recursos compartilhados:** tipos reutilizáveis, esquemas de banco de dados, configuração de servidores e coleções de requisições HTTP.

<br />

- **Testes:** configuração do _Jest_ e testes de _backend_ com _Supertest_.

<br />

- **Ferramentas:** configuração do _TypeScript_ e um _script_ de _shell_ para gerar a árvore de diretórios.

<br />

Essa organização permite que os experimentos permaneçam independentes, ao mesmo tempo que possibilita o compartilhamento de código quando a reutilização oferece benefícios práticos.

<br />

## Tópicos

<br />

O repositório explora diferentes aspectos do desenvolvimento de _software_, incluindo:

<br />

- Linguagens de programação, _runtimes_ e APIs nativas.
- Desenvolvimento de _backend_ e arquiteturas do lado do servidor.
- Servidores HTTP, roteamento, _middlewares_ e _design_ de APIs.
- _Frameworks_, bibliotecas e integrações nativas.
- Esquemas de banco de dados, persistência e acesso a dados.
- Integrações com _SQLite_ e _Supabase_.
- Autenticação, JWTs e _hashing_ de senhas.
- Sistemas de módulos do _JavaScript_ e configuração do _TypeScript_.
- Módulos compartilhados, organização de dependências e estrutura de projetos.
- Testes automatizados e ferramentas de desenvolvimento.
- Implementações alternativas para problemas semelhantes.
- _Shell scripting_ e fundamentos da linha de comando.

<br />

Esses tópicos representam áreas de investigação, não um roteiro fixo.

<br />

Novos experimentos poderão incorporar outras linguagens, _frameworks_ e ferramentas conforme novas perguntas surgirem.

<br />

## Estrutura

<br />

A organização principal separa os experimentos por linguagem e domínio de desenvolvimento.

<br />

```
codelabs/
├── languages/
│   ├── bash/
│   │   └── intro/
│   │       ├── conditions.sh
│   │       └── variables.sh
│   └── js/
│       ├── backend/
│       │   └── node/
│       │       ├── README.md
│       │       ├── concepts/
│       │       ├── frameworks/
│       │       └── shared/
│       ├── tests/
│       │   └── jest/
│       │       └── backend/
│       │           └── supertest/
│       ├── jest.config.ts
│       └── tsconfig.json
├── scripts/
│   └── filetree.sh
└── README.md
```

<br />

A árvore acima destaca os principais pontos de entrada.

<br />

Os diretórios de cada experimento contêm suas próprias implementações, configurações e recursos de apoio.

<br />

### _Bash_

<br />

**Localização:** [`languages/bash/`](https://github.com/thiagonddev/codelabs/tree/master/languages/bash/)

<br />

Experimentos introdutórios de _shell scripting_ que abordam:

<br />

- `variables.sh` — fundamentos de variáveis.
- `conditions.sh` — execução condicional.

<br />

Esses exemplos fornecem uma base para explorar a sintaxe do _shell_, práticas de _scripting_ e automação pela linha de comando.

<br />

### _JavaScript_ e _Node.js_

<br />

**Localização:** [`languages/js/backend/node/`](https://github.com/thiagonddev/codelabs/tree/master/languages/js/backend/node)

<br />

O espaço dedicado ao _Node.js_ concentra-se no desenvolvimento de backend com _JavaScript_ e _TypeScript_.

Sua estrutura separa experimentos de nível mais baixo, implementações específicas de _frameworks_ e recursos compartilhados.

<br />

#### `concepts/`

<br />

Explorações dos fundamentos do _Node.js_ e de seus recursos nativos, organizadas em `concepts/commonjs/`.

<br />

As áreas atuais incluem:

<br />

- **Acesso a bancos de dados:** integrações com _SQLite_ nativo e _Supabase_.
- **APIs do sistema operacional:** experimentos com o módulo `os` do _Node.js_.
- **Servidores HTTP:** implementações básicas de servidores e tratamento de rotas.
- **_CommonJS_:** organização de módulos e conceitos relacionados ao _runtime_.

<br />

Esses experimentos ajudam a isolar os mecanismos subjacentes das abstrações oferecidas por _frameworks_, facilitando a compreensão de seu comportamento e de seus custos e benefícios.

<br />

#### `frameworks/`

<br />

As implementações orientadas a _frameworks_ concentram-se atualmente no _Express_ com _CommonJS_.

<br />

O diretório contém experimentos relacionados a:

<br />

- **Fundamentos de servidores:** aplicações básicas e pontos de entrada de servidores.
- **Comportamento HTTP:** roteamento e configuração de CORS.
- **Integração com bancos de dados:** implementações com _SQLite_ nativo.
- **Autenticação:** fluxos baseados em JWT, _hashing_ de senhas com _bcrypt_ e autenticação com persistência em _SQLite_.

<br />

A separação entre implementações baseadas em _frameworks_ e experimentos de runtime facilita a comparação entre abstrações de nível mais alto e abordagens de nível mais baixo.

<br />

#### `shared/`

<br />

**Localização:** [`languages/js/backend/node/shared/`](https://github.com/thiagonddev/codelabs/tree/master/languages/js/backend/node/shared)

<br />

Recursos reutilizáveis para experimentos relacionados, incluindo:

<br />

- Tipos de autenticação e esquemas de banco de dados.
- Esquemas _SQLite_ e integração com o banco de dados _Supabase_.
- Tipos compartilhados relacionados a bancos de dados.
- Configuração de servidores.
- Coleções de requisições HTTP para exploração manual de APIs.

<br />

Os recursos compartilhados são introduzidos quando ajudam a manter a consistência ou reduzem duplicações relevantes.

<br />

Eles não são dependências obrigatórias para todos os experimentos.

<br />

### Testes

<br />

**Localização:** [`languages/js/tests/`](https://github.com/thiagonddev/codelabs/tree/master/languages/js/tests)

<br />

O espaço de testes contém os testes de _backend_ desenvolvidos com _Jest_ + _Supertest_.

<br />

Os testes atuais abrangem implementações _Express_ envolvendo:

<br />

- Comportamento básico de servidores.
- Tratamento de rotas HTTP.
- Integração com bancos de dados _SQLite_ nativos.

<br />

Essa estrutura oferece um espaço dedicado à verificação de _endpoints_, aos testes de integração e à validação automatizada do comportamento dos servidores.

<br />

A configuração do _Jest_ está em `languages/js/jest.config.ts`, junto à configuração do _TypeScript_ em `languages/js/tsconfig.json`.

<br />

### _Scripts_ e Ferramentas

<br />

**Localização:** [`scripts/`](https://github.com/thiagonddev/codelabs/tree/master/scripts)

<br />

O script `filetree.sh` auxilia na inspeção do repositório ao gerar uma representação de sua árvore de diretórios.

Essa ferramenta complementa o fluxo de experimentação, tornando a organização do código mais fácil de inspecionar e documentar.

<br />

### Organização dos Experimentos

<br />

Cada experimento pode conter arquivos-fonte, esquemas de banco de dados, exemplos de requisições HTTP, testes e outros recursos de apoio, de acordo com seu escopo.

<br />

A estrutura interna permanece deliberadamente flexível.

<br />

Uma demonstração simples de um recurso do _runtime_ pode exigir apenas um arquivo-fonte, enquanto um experimento com APIs pode envolver pontos de entrada para aplicação e servidor, roteamento, acesso a dados, configuração de ambiente e testes automatizados.

<br />

As dependências e configurações podem ser definidas em diretórios específicos quando necessário.

<br />

Isso preserva a independência dos experimentos e facilita a comparação entre implementações alternativas, sem introduzir acoplamento desnecessário.

<br />

## Foco Atual

<br />

O foco principal é o **desenvolvimento de backend com _Node.js_ e _TypeScript_**, com ênfase tanto nos fundamentos do desenvolvimento no lado do servidor quanto nas abstrações oferecidas por _frameworks_.

<br />

As áreas de exploração atuais incluem:

<br />

- Comportamento do _runtime_ do _Node.js_, APIs nativas e _CommonJS_.
- Servidores HTTP, tratamento de requisições e roteamento.
- Aplicações _Express_, _middlewares_ e CORS.
- Integrações com _SQLite_ nativo e _Supabase_.
- Esquemas de banco de dados, persistência e acesso a dados.
- Autenticação baseada em JWT e _hashing_ de senhas com _bcrypt_.
- Tipos, declarações e configuração do compilador _TypeScript_.
- Módulos compartilhados e organização de dependências.
- Testes automatizados com _Jest_ e _Supertest_.
- Variáveis e execução condicional em _Bash_.

<br />

Essas áreas refletem o conteúdo atual do repositório, não um escopo permanente.

<br />

O foco poderá evoluir conforme os experimentos existentes avancem e novos objetivos de aprendizado surjam.

<br />

## Filosofia

<br />

O princípio que orienta o _`codelabs`_ é simples: **aprender construindo.**

<br />

Utilizo este repositório para:

<br />

- Explorar conceitos desconhecidos por meio de implementações práticas.
- Dividir sistemas complexos em experimentos menores e compreensíveis.
- Comparar soluções alternativas e abordagens arquiteturais.
- Investigar o comportamento do _runtime_, APIs, dependências e ferramentas.
- Compreender os custos e benefícios relacionados à simplicidade, abstração, manutenibilidade e flexibilidade.
- Testar ideias isoladamente antes de incorporá-las a projetos maiores.
- Preservar descobertas úteis para consultas futuras.

<br />

Cada experimento deve ter um objetivo de aprendizado, mesmo quando esse objetivo consiste apenas em responder a uma pergunta ou observar o comportamento de determinado mecanismo.

<br />

O código nem sempre precisa ser elegante, completo ou estar pronto para produção.

<br />

Alguns experimentos priorizam a simplicidade; outros investigam deliberadamente uma decisão de design ou revelam limitações de uma abordagem inicial.

<br />

**O objetivo principal é compreender.**

<br />

## Observações Finais

<br />

O _`codelabs`_ está em constante evolução.

<br />

Seu código, suas dependências, convenções, documentação e estruturas de diretórios podem mudar conforme os experimentos avançam e meu entendimento se aprofunda.

Algumas explorações podem permanecer incompletas ou nunca ultrapassar a etapa de prova de conceito; outras podem ser refatoradas, substituídas, combinadas ou expandidas em implementações mais elaboradas.

<br />

Isso é intencional.

<br />

Nem todo experimento precisa se transformar em uma aplicação finalizada, assim como nem toda implementação precisa ser reutilizável.

O escopo de cada experimento é determinado pela pergunta que ele pretende responder.

<br />

Compreender por que uma abordagem funciona, por que falha, quais custos e benefícios apresenta ou como se compara a uma alternativa já é, por si só, um resultado válido.

<br />

---

<br />

> _codelabs is about exploration, not perfection_.
