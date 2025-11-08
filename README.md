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

O projeto adota Atomic Design para UI e foi iniciado o refino para princípios da Clean Architecture (UI/Presentation, Domain, Data) com Riverpod para gerenciamento de estado.

Camadas e principais arquivos:

- Presentation/UI
	- `lib/screens/*` (páginas)
	- `lib/components/*` (Atomic Design)
	- Estado/DI: `lib/presentation/state/providers.dart` (providers, `SearchController` e `SearchState`)
- Domain
	- Repositório: `lib/domain/repositories/books_repository.dart`
	- Casos de uso: `lib/domain/usecases/search_books.dart`, `lib/domain/usecases/get_work_details.dart`
- Data
	- Implementação: `lib/data/repositories/books_repository_impl.dart`
	- Cliente HTTP: `lib/services/book_service.dart`

O app inicializa com `ProviderScope` em `lib/main.dart` e as telas consomem providers conforme necessário.

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
`ForgotPasswordPage` envia e-mail de reset via Firebase quando configurado; SMS é placeholder (necessita Phone Auth configurado e verificação). 

### Próximos passos sugeridos
- Implementar Phone Auth (verificação SMS) se necessário.
- Adicionar testes widget cobrindo fluxo de reset de senha.
- Centralizar mensagens de erro/sucesso em um serviço de UI para internacionalização futura.
- Persistir carrinho entre sessões (ex.: `shared_preferences` ou Firestore).

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