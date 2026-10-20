🇺🇸 [EN](#-codelabs) <br>
🇧🇷 [PT](#-codelabs-1)

<br />

# (🇺🇸) codelabs

<br />

> _A personal monorepo for experimentation, prototyping & continuous learning._

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

**codelabs** is my personal workspace for exploring technologies, prototyping ideas & understanding how software works under the hood.

<br />

Rather than serving as a collection of polished portfolio projects, this repository is a laboratory for experimentation: a place to investigate unfamiliar tools, compare implementations, explore architectural decisions & learn through hands-on development.

<br />

I treat these experiments as **knowledge drafts** — small, focused explorations designed to answer questions, test hypotheses, validate ideas or deepen my understanding of a specific concept, technology or development practice.

<br />

Some experiments may evolve into more complete applications or become building blocks for future projects.

<br />

Others may remain isolated proofs of concept, serving only to clarify an idea, demonstrate a technique or uncover how a particular tool or mechanism works.

<br />

The repository is intentionally exploratory.

<br />

Its value lies not only in the code it contains, but also in the knowledge gained from writing, testing, comparing & refining it.

<br />

## Topics

<br />

The repository explores different areas of software development, with an emphasis on practical implementation & understanding the relationships between technologies, including:

<br />

- Programming languages, runtimes and built-in APIs
- Backend development & server-side architectures
- Frameworks, libraries and middleware
- Database integrations, schema design & data access
- HTTP servers, routing and API design
- Authentication, authorization & security mechanisms
- TypeScript, module systems and project configuration
- Code organization, shared modules & reusable infrastructure
- Automated testing, development workflows and tooling
- Alternative implementations of similar problems

<br />

The goal isn't necessarily to build production-ready software or adopt a single architectural approach.

<br />

Sometimes, the most valuable outcome is understanding a fundamental concept, identifying a trade-off or discovering why one implementation is more appropriate than another.

<br />

## Structure

<br />

The repository is organized by language, runtime & area of experimentation rather than around a single application, framework or architectural pattern.

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
│               ├── tests/
│               ├── package.json
│               └── tsconfig.json
├── .github/
├── .gitignore
├── .vsls.json
├── commands.sh
└── README.md

```

<br />

The `languages/` directory groups experiments by programming language and development domain.

Within each area, directories reflect the technologies, concepts or implementation strategies being investigated.

<br />

The repository also includes supporting configuration, automation scripts & project-level tooling.

Individual experiments may maintain their own dependencies, lockfiles, configuration files & test infrastructure where appropriate.

<br />

### Node.js

<br />

The Node.js workspace is primarily focused on backend development with JavaScript & TypeScript.

<br />

Its organization separates runtime concepts, framework-specific implementations & shared resources:

<br />

```

node/
├── concepts/
│   └── commonjs/
├── frameworks/
│   └── express/
│       └── commonjs/
├── shared/
│   ├── auth/
│   ├── database/
│   └── server/
├── tests/
└── package.json

```

#### `concepts/`

Experiments focused on Node.js fundamentals, built-in modules, runtime behavior & core development concepts.

<br />

Examples include:

<br />

- HTTP servers, request handling & routing
- Operating system APIs and process-level utilities
- Database access using SQLite & Supabase
- CommonJS module resolution and organization
- Native integrations & interactions with external services

<br />

These experiments help isolate individual concepts from framework-specific abstractions, making it easier to understand the underlying mechanisms & their trade-offs.

<br />

#### `frameworks/`

Experiments focused on framework-specific implementations, integrations & architectural patterns.

<br />

Current explorations include Express applications, middleware, HTTP routing, CORS configuration, authentication flows, JWT-based mechanisms, password hashing & database integrations.

<br />

The framework-oriented structure makes it possible to investigate how these concerns are implemented in a more opinionated environment while comparing them with lower-level Node.js approaches.

<br />

#### `shared/`

Reusable code, shared definitions & supporting infrastructure used across related experiments, including:

<br />

- Authentication-related types and database schemas
- Database schemas, configuration & integrations
- SQLite and Supabase access layers
- Server configuration & environment handling
- Shared TypeScript types and definitions
- Example environment files & HTTP request collections

<br />

Shared resources are separated from individual implementations to reduce unnecessary duplication & establish consistent definitions where reuse is beneficial.

<br />

However, shared code is not an architectural requirement for every experiment.

<br />

Abstractions are introduced when they provide a practical benefit, rather than forcing unrelated examples into a common structure.

<br />

#### `tests/`

Automated testing experiments & supporting test infrastructure, including Jest configuration and backend integration tests with Supertest.

<br />

This area provides a place to explore test organization, HTTP endpoint verification & techniques for validating server behavior independently of manual requests.

<br />

### Experiment Organization

<br />

Individual experiments may contain their own source files, dependencies, package manifests, lockfiles, configuration, database schemas, API request examples, tests & documentation.

<br />

The internal structure is intentionally flexible.

<br />

Each experiment can adopt the organization & level of abstraction that best fit the problem being explored.

<br />

**Ex.:**

<br />

> A small runtime demonstration may need only a source file, while an API experiment may require a server entry point, route definitions, environment configuration, database integration & automated tests.

<br />

Dependencies & tooling may also be scoped to individual directories when an experiment requires a different setup.

<br />

This helps preserve the independence of examples & makes it easier to compare alternative implementations without introducing unnecessary coupling.

<br />

## Current Focus

<br />

The repository currently focuses primarily on **backend development with Node.js & TypeScript**, exploring the fundamentals of server-side development alongside framework-based implementations.

<br />

Areas of exploration include:

<br />

- Node.js runtime behavior, built-in APIs & CommonJS modules
- HTTP servers, request handling, routing and middleware
- Express applications, application configuration & CORS
- SQLite and Supabase integrations
- Database schemas, data access & persistence
- API design, endpoint behavior and HTTP request testing
- Authentication, JWTs & password hashing with bcrypt
- TypeScript types, declarations and compiler configuration
- Shared modules, dependency organization & project structure
- Automated testing with Jest and Supertest
- Bash fundamentals, variables & conditional execution

<br />

The current directory structure reflects these interests, but it is not intended to define a permanent scope for the repository.

<br />

Other languages, frameworks, tools & development topics may be introduced as new questions arise and existing experiments evolve.

<br />

## Philosophy

<br />

The guiding principle behind codelabs is simple: **learn by building.**

<br />

I use this repository to:

<br />

- Explore unfamiliar concepts through small, practical implementations.
- Break down complex systems into focused, understandable experiments.
- Compare alternative implementations & architectural approaches.
- Evaluate libraries, frameworks and tools before adopting them in larger projects.
- Investigate runtime behavior, APIs, dependencies & development workflows.
- Understand trade-offs involving simplicity, abstraction, maintainability and flexibility.
- Test ideas in isolation without introducing unnecessary complexity.
- Record experiments & preserve useful knowledge for future reference.

<br />

Each experiment should have a clear learning objective, even if that objective is simply answering a question or observing how a particular mechanism behaves.

<br />

The code doesn't always need to be elegant, complete or production-ready.

<br />

Some examples may prioritize simplicity, others may deliberately explore a particular design choice & some may expose limitations or incorrect assumptions along the way.

<br />

**The primary goal is understanding.**

<br />

## Final Notes

<br />

This repository is a work in progress.

<br />

Its code, dependencies, conventions, documentation & directory structures may change as experiments develop and my understanding improves.

<br />

Some experiments may remain incomplete or never progress beyond a proof of concept; others may be refactored, replaced, combined or expanded into more substantial implementations.

<br />

That's intentional.

<br />

Not every experiment needs to become a finished application and/or needs to be reusable.

The scope of each example is determined by the question it aims to answer.

<br />

Understanding why an approach works, why it fails, what trade-offs it introduces or how it compares with an alternative is a worthwhile outcome in itself.

<br />

---

<br />

# (🇧🇷) codelabs

<br />

> _Um monorepo pessoal para experimentação, prototipagem e aprendizado contínuo._

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

**_codelabs_** é meu espaço pessoal para explorar tecnologias, prototipar ideias e compreender como o software funciona por baixo dos panos.

<br />

Em vez de ser uma coleção de projetos de portfólio finalizados, este repositório funciona como um laboratório de experimentação: um lugar para investigar ferramentas desconhecidas, comparar implementações, explorar decisões arquiteturais e aprender por meio do desenvolvimento prático.

<br />

Encaro esses experimentos como **rascunhos de conhecimento** (_knowledge drafts_) — explorações pequenas e focadas, criadas para responder perguntas, testar hipóteses, validar ideias ou aprofundar meu entendimento sobre determinado conceito, tecnologia ou prática de desenvolvimento.

<br />

Alguns experimentos podem evoluir para aplicações mais completas ou se tornar componentes úteis para projetos futuros.

<br />

Outros podem permanecer como provas de conceito isoladas, existindo apenas para esclarecer uma ideia, demonstrar uma técnica ou descobrir como determinada ferramenta ou mecanismo funciona.

<br />

O repositório é intencionalmente exploratório.

<br />

Seu valor está não apenas no código que contém, mas também no conhecimento adquirido ao escrevê-lo, testá-lo, compará-lo e aprimorá-lo.

<br />

## Tópicos

<br />

O repositório explora diferentes áreas do desenvolvimento de _software_, com ênfase na implementação prática e na compreensão das relações entre tecnologias, incluindo:

<br />

- Linguagens de programação, ambientes de execução (_runtimes_) e APIs nativas
- Desenvolvimento de _backend_ e arquiteturas do lado do servidor
- _Frameworks_, bibliotecas e _middlewares_
- Integrações com bancos de dados, modelagem de esquemas e acesso a dados
- Servidores HTTP, roteamento e design de APIs
- Mecanismos de autenticação, autorização e segurança
- _TypeScript_, sistemas de módulos e configuração de projetos
- Organização de código, módulos compartilhados e infraestrutura reutilizável
- Testes automatizados, fluxos de desenvolvimento e ferramentas
- Implementações alternativas para problemas semelhantes

<br />

O objetivo não é necessariamente construir software pronto para produção ou adotar uma única abordagem arquitetural.

<br />

Às vezes, o resultado mais valioso é compreender um conceito fundamental, identificar uma relação de custo e benefício ou descobrir por que determinada implementação é mais adequada do que outra.

<br />

## Estrutura

<br />

O repositório é organizado por linguagem, _runtime_ e área de experimentação, em vez de seguir a estrutura de uma única aplicação, _framework_ ou padrão arquitetural.

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
│               ├── tests/
│               ├── package.json
│               └── tsconfig.json
├── .github/
├── .gitignore
├── .vsls.json
├── commands.sh
└── README.md

```

<br />

O diretório `languages/` agrupa os experimentos por linguagem de programação e área de desenvolvimento.

Dentro de cada área, os diretórios refletem as tecnologias, os conceitos ou as estratégias de implementação investigadas.

<br />

O repositório também inclui arquivos de configuração, _scripts_ de automação e ferramentas de apoio ao desenvolvimento.

Quando necessário, cada experimento pode manter suas próprias dependências, arquivos de bloqueio de versões, configurações e infraestrutura de testes.

<br />

### _Node.js_

<br />

O espaço dedicado ao _Node.js_ é voltado principalmente ao desenvolvimento de _backend_ com _JavaScript_ e _TypeScript_.

<br />

Sua organização separa conceitos do _runtime_, implementações específicas de _frameworks_ e recursos compartilhados:

<br />

```

node/
├── concepts/
│   └── commonjs/
├── frameworks/
│   └── express/
│       └── commonjs/
├── shared/
│   ├── auth/
│   ├── database/
│   └── server/
├── tests/
└── package.json

```

#### `concepts/`

Experimentos voltados aos fundamentos do _Node.js_, aos módulos nativos, ao comportamento do _runtime_ e aos conceitos essenciais do desenvolvimento.

<br />

Exemplos incluem:

<br />

- Servidores HTTP, tratamento de requisições e roteamento
- APIs do sistema operacional e utilitários relacionados a processos
- Acesso a bancos de dados com _SQLite_ e _Supabase_
- Resolução e organização de módulos _CommonJS_
- Integrações nativas e comunicação com serviços externos

<br />

Esses experimentos ajudam a isolar conceitos individuais das abstrações oferecidas por _frameworks_, facilitando a compreensão dos mecanismos subjacentes e de seus custos e benefícios.

<br />

#### `frameworks/`

Experimentos voltados a implementações específicas de _frameworks_, integrações e padrões arquiteturais.

<br />

As explorações atuais incluem aplicações _Express_, _middlewares_, roteamento HTTP, configuração de CORS, fluxos de autenticação, mecanismos baseados em JWT, _hashing_ de senhas e integrações com bancos de dados.

<br />

A organização orientada a _frameworks_ permite investigar como essas responsabilidades são implementadas em um ambiente mais opinativo, comparando essas soluções com abordagens de nível mais baixo no _Node.js_.

<br />

#### `shared/`

Código reutilizável, definições compartilhadas e infraestrutura de apoio utilizadas entre experimentos relacionados, incluindo:

<br />

- Tipos e esquemas relacionados à autenticação
- Esquemas, configurações e integrações com bancos de dados
- Camadas de acesso a _SQLite_ e _Supabase_
- Configuração de servidores e gerenciamento de variáveis de ambiente
- Tipos e definições compartilhadas em _TypeScript_
- Arquivos de exemplo para variáveis de ambiente e coleções de requisições HTTP

<br />

Os recursos compartilhados são separados das implementações individuais para reduzir duplicações desnecessárias e estabelecer definições consistentes quando o reaproveitamento é vantajoso.

<br />

Entretanto, o uso de código compartilhado não é uma exigência arquitetural para todos os experimentos.

<br />

As abstrações são introduzidas quando oferecem um benefício prático, sem forçar exemplos independentes a seguir uma estrutura comum.

<br />

#### `tests/`

Experimentos com testes automatizados e infraestrutura de apoio, incluindo a configuração do _Jest_ e testes de integração de _backend_ com _Supertest_.

<br />

Essa área permite explorar a organização de testes, a verificação de _endpoints_ HTTP e técnicas para validar o comportamento de servidores sem depender exclusivamente de requisições manuais.

<br />

### Organização dos Experimentos

<br />

Cada experimento pode conter seus próprios arquivos-fonte, dependências, manifestos de pacotes, arquivos de bloqueio de versões, configurações, esquemas de banco de dados, exemplos de requisições HTTP, testes e documentação.

<br />

A estrutura interna é intencionalmente flexível. Cada experimento pode adotar a organização e o nível de abstração mais adequados ao problema explorado.

<br />

**Ex.:**

<br />

> Uma demonstração simples de um recurso do _runtime_ pode precisar apenas de um arquivo-fonte, enquanto um experimento com APIs pode exigir um ponto de entrada para o servidor, definições de rotas, configuração de ambiente, integração com banco de dados e testes automatizados.

<br />

As dependências e ferramentas também podem ser definidas em diretórios específicos quando um experimento exige uma configuração diferente.

<br />

Isso ajuda a preservar a independência dos exemplos e facilita a comparação entre implementações alternativas, sem introduzir acoplamento desnecessário.

<br />

## Foco Atual

<br />

Atualmente, o repositório se concentra principalmente no **desenvolvimento de _backend_ com _Node.js_ e _TypeScript_**, explorando tanto os fundamentos do desenvolvimento no lado do servidor quanto implementações baseadas em _frameworks_.

<br />

As áreas de exploração incluem:

<br />

- Comportamento do _runtime_ do _Node.js_, APIs nativas e módulos _CommonJS_
- Servidores HTTP, tratamento de requisições, roteamento e _middlewares_
- Aplicações _Express_, configuração de aplicações e CORS
- Integrações com _SQLite_ e _Supabase_
- Esquemas de banco de dados, acesso a dados e persistência
- Design de APIs, comportamento de _endpoints_ e testes de requisições HTTP
- Autenticação, JWTs e _hashing_ de senhas com _bcrypt_
- Tipos, declarações e configuração do compilador _TypeScript_
- Módulos compartilhados, organização de dependências e estrutura de projetos
- Testes automatizados com _Jest_ e _Supertest_
- Fundamentos de _Bash_, variáveis e execução condicional

<br />

A estrutura atual dos diretórios reflete esses interesses, mas não pretende estabelecer um escopo permanente para o repositório.

<br />

Outras linguagens, _frameworks_, ferramentas e áreas do desenvolvimento poderão ser adicionados conforme novas perguntas surgirem e os experimentos existentes evoluírem.

<br />

## Filosofia

<br />

O princípio que orienta o _codelabs_ é simples: **aprender construindo.**

<br />

Uso este repositório para:

<br />

- Explorar conceitos desconhecidos por meio de implementações pequenas e práticas.
- Dividir sistemas complexos em experimentos focados e compreensíveis.
- Comparar implementações alternativas e abordagens arquiteturais.
- Avaliar bibliotecas, _frameworks_ e ferramentas antes de adotá-los em projetos maiores.
- Investigar o comportamento do _runtime_, APIs, dependências e fluxos de desenvolvimento.
- Compreender os custos e benefícios relacionados à simplicidade, abstração, manutenibilidade e flexibilidade.
- Testar ideias isoladamente, sem introduzir complexidade desnecessária.
- Registrar experimentos e preservar conhecimentos úteis para consultas futuras.

<br />

Cada experimento deve ter um objetivo de aprendizado claro, mesmo que esse objetivo seja apenas responder a uma pergunta ou observar o comportamento de determinado mecanismo.

<br />

O código nem sempre precisa ser elegante, completo ou estar pronto para produção.

<br />

Alguns exemplos podem priorizar a simplicidade; outros podem explorar deliberadamente uma decisão de _design_ e alguns podem revelar limitações ou pressupostos incorretos ao longo do processo.

<br />

**O objetivo principal é a compreensão.**

<br />

## Observações Finais

<br />

Este repositório está em constante evolução.

Seu código, suas dependências, convenções, documentação e estruturas de diretórios podem mudar conforme os experimentos avançam e meu entendimento se aprofunda.

<br />

Alguns experimentos podem permanecer incompletos ou nunca ultrapassar a etapa de prova de conceito; outros podem ser refatorados, substituídos, combinados ou expandidos em implementações mais elaboradas.

<br />

Isso é intencional.

<br />

Nem todo experimento precisa se transformar em uma aplicação finalizada, assim como nem toda implementação precisa ser reutilizável.

O escopo de cada exemplo é determinado pela pergunta que ele pretende responder.

<br />

Compreender por que uma abordagem funciona, por que falha, quais custos e benefícios apresenta ou como se compara a uma alternativa já é, por si só, um resultado válido.

<br />

---

<br />

> _codelabs is about exploration, not perfection_.
