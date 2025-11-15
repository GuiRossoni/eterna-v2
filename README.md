# Eterna V2 — Biblioteca Virtual

## Funcionalidades implementadas (atualizado)

- Arquitetura (Atomic Design)
	- Componentes organizados em `lib/components/atoms`, `molecules` e `organisms`.
	- Telas em `lib/screens`, serviços em `lib/services` e modelos em `lib/models`.

- Busca via Open Library (com paginação e cache)
	- Integração com `https://openlibrary.org/search.json` e capas pela Covers API.
	- Paginação infinita nos “Resultados”, com loader discreto e cache da primeira página.
	- Arquivos: `lib/services/book_service.dart`, `lib/screens/home_page.dart`, `lib/components/organisms/book_section.dart`.

- Detalhes enriquecidos do livro
	- Ao abrir um resultado, a página exibe autores/ano (da busca) e complementa com descrição e assuntos via `/works/{id}.json`.
	- Arquivos: `lib/screens/book_details_page.dart`, `lib/components/organisms/book_details_content.dart`.

- Formulários e validação (Cadastro)
	- Máscara de Data de Nascimento (`dd/mm/aaaa`) com validação forte (formato, data real, não-futuro, ano ≥ 1900).
	- Máscara de celular brasileiro com validação de 10–11 dígitos.
	- Validações de e-mail, senha (mín. 6) e endereço.
	- Arquivo: `lib/screens/register_page.dart` (inclui `DateInputFormatter` e `PhoneInputFormatter`) e `lib/components/molecules/app_text_field.dart`.

- Microinterações e Acessibilidade
	- `Hero` com tags únicas por item; `AnimatedScale` no `BookCard`.
	- `Semantics` nas imagens e botões; foco com outline visível.
	- `Scrollbar` funcional (vertical e horizontal) com `ScrollController` dedicado.
	- Arquivos: `lib/components/atoms/book_cover.dart`, `lib/components/molecules/book_card.dart`, `lib/screens/home_page.dart`, `lib/components/organisms/book_section.dart`.

- Estabilidade e Build Android
	- Correção de overflows na página de detalhes com rolagem única.
	- `ndkVersion` fixado no Gradle para compatibilidade de build Android.
	- Arquivos: `lib/screens/book_details_page.dart`, `android/app/build.gradle.kts`.

Observação: Páginas de demonstração antigas foram removidas da navegação para focar no app principal.

## Arquitetura e Organização

### Visão conceitual

O app combina **Atomic Design** para a camada visual com uma abordagem **MVVM + Clean Architecture** no restante da stack. Em alto nível:

- **Presentation (View + ViewModel)**
  - As *Views* são widgets declarativos nas pastas `lib/screens` e `lib/components`. Elas não contêm regra de negócio, apenas composição de UI.
  - Os *ViewModels* são providos por Riverpod (`lib/presentation/state/providers.dart`), expondo estados (`AsyncValue`, `StateNotifier`) para as telas. Isso garante testabilidade (basta mockar providers) e substituição simples de dependências.
- **Domain**
  - Define modelos imutáveis e contratos (`lib/models`, `lib/domain/repositories/*`).
  - Casos de uso (`lib/domain/usecases/*`) encapsulam regras como buscar livros ou obter detalhes. Como são funções puras/reporters, são fáceis de cobrir com testes unitários.
- **Data**
  - Implementa os contratos através de serviços (`lib/services/book_service.dart`, `lib/services/listing_service.dart`) e repositórios (`lib/data/repositories/*`).
  - Qualquer mudança de backend (ex.: trocar Open Library por outro provedor) fica isolada aqui.

Essa separação faz com que cada módulo tenha dependências unidirecionais (Presentation → Domain → Data). O resultado é uma base modular, onde componentes da UI podem ser reutilizados, estados podem ser testados isoladamente e serviços podem evoluir sem quebrar a camada visual.

### Estrutura de pastas

```
lib/
├── components/
│   ├── atoms/
│   ├── molecules/
│   └── organisms/
├── data/
│   └── repositories/
├── domain/
│   ├── repositories/
│   └── usecases/
├── models/
├── presentation/
│   └── state/
├── screens/
├── services/
└── widgets/
```

- **components/**: implementação do Atomic Design, garantindo reutilização e consistência visual.
- **screens/**: páginas que orquestram componentes e assinam providers.
- **presentation/state/**: *ViewModels* (Riverpod providers, `SearchController`, filtros de listagem, carrinho etc.).
- **domain/**: contratos e casos de uso (ex.: `search_books.dart`, `get_work_details.dart`).
- **data/**: repositórios concretos ligados a APIs ou Firebase.
- **services/**: integrações externas (Open Library, Firestore, Firebase Auth).
- **models/**: entidades puras usadas em todas as camadas.
- **widgets/**: utilitários de UI genéricos (tema, `GlassPanel`).

### Contribuições para modularidade, testabilidade e manutenção

- **Modularidade**: a pasta `components` permite evoluir a UI sem tocar em lógica; mudanças de dados ficam nos serviços/repositórios sem impactar as telas.
- **Testabilidade**: `StateNotifier`/`FutureProvider` expõem estados previsíveis. Casos de uso no domínio não dependem de Flutter, facilitando testes unitários. Serviços podem ser mockados via providers.
- **Manutenção**: camadas bem definidas tornam refactors localizados. Ex.: adicionar novo tipo de anúncio tocou apenas em `listing_service.dart`, `providers.dart` e componentes específicos.

O app inicia com `ProviderScope` (`lib/main.dart`), garantindo que qualquer tela use as mesmas instâncias de estado/injeção com escopo controlado.

## Onde encontrar (arquivos principais)

- Tema e UI base: `lib/widgets/shared.dart` (inclui `GlassPanel` e paleta).
- Componentes (Atomic Design):
	- Átomos: `lib/components/atoms/` (ex.: `book_cover.dart`, `app_button.dart`).
	- Moléculas: `lib/components/molecules/` (ex.: `book_card.dart`, `app_text_field.dart`).
	- Organismos: `lib/components/organisms/` (ex.: `book_section.dart`, `book_details_content.dart`).
- Fluxo e navegação:
	- Home/Busca: `lib/screens/home_page.dart`.
	- Detalhes: `lib/screens/book_details_page.dart`.
	- Cadastro: `lib/screens/register_page.dart`.
- API/Modelo:
	- Serviço de livros: `lib/services/book_service.dart`.
	- Modelo: `lib/models/book_model.dart`.

## Dependências

- `google_fonts` para tipografia.
- `http` para requisições REST.
 - `flutter_riverpod` para estado e injeção.
 - `firebase_core` / `firebase_auth` para autenticação (registrar, login, reset de senha) com fallback local.

## Notas técnicas

- Hero: tag única por item combinando seção + título + índice.
- Scrollbar: sempre ligada ao mesmo `ScrollController` do widget rolável correspondente.
- Máscaras: `DateInputFormatter` e `PhoneInputFormatter` preservam a posição do cursor.
- Cache de busca: primeira página por termo (balanceando simplicidade e performance).

## 🔐 Firebase Auth (Setup)

O projeto agora tenta usar Firebase Authentication (registro / login / reset) antes de cair em um serviço local simples.

### Sobre inicialização preguiçosa
`FirebaseAuthService` só acessa `FirebaseAuth.instance` após verificar se `Firebase.initializeApp()` foi bem-sucedido, evitando erros em builds Web sem configuração (`TypeError: ... JavaScriptObject`). Se Firebase não estiver pronto, os métodos retornam `null` silenciosamente e o fallback local é usado.

### Recuperação de senha
`ForgotPasswordPage` envia e-mail de reset via Firebase quando configurado. 

# 📚 Eterna Livraria

A **Eterna Livraria** é um projeto que simula uma plataforma de compra, venda e troca de livros novos e usados.  
O objetivo é oferecer uma experiência simples e intuitiva para que os leitores possam encontrar, anunciar e trocar livros de forma prática.

---

## 🚀 Telas

- **Login** — acesso ao sistema com credenciais do usuário.
- **Cadastro** — criação de nova conta com validações e máscaras.
- **Esqueci a Senha** — recuperação por e-mail/celular.
- **Catálogo e Busca** — carrosséis e resultados via Open Library.

---

## 🛠️ Objetivo do Projeto

Base de uma plataforma completa de livraria digital, permitindo: comprar, vender e trocar exemplares entre usuários.