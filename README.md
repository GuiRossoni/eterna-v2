# Eterna V2 — Biblioteca Virtual

Este projeto foi ajustado para o desafio de Refatoração UI/UX Inicial. Abaixo estão as entregas e as escolhas técnicas realizadas.
## Funcionalidades implementadas

- Atomic Design:
	- Átomo `AtomButton` e Molécula `MoleculeTextField` em `lib/widgets/atomic_demo.dart`.
	- Tela de login refatorada para usar estes componentes.
- Microinterações:
	- Uso de `InkWell` com efeito de splash em botões e itens clicáveis.
	- `SnackBar` de feedback em ações (ex.: busca e login inválido).
	- Animação `Hero` entre a capa do livro na Home e a página de detalhes.
- Acessibilidade (básico):
	- Adição de `Semantics` e `tooltip` em elementos chave (botões, imagens, links).
	- Contraste adequado através do tema e paleta em `lib/widgets/shared.dart`.
- Consumo de API:
	- Tela `ApiDemoPage` (`lib/screens/api_demo_page.dart`) consome a API pública JSONPlaceholder (`/posts`).
	- Uso de `FutureBuilder` para dados assíncronos e estados de carregamento/erro/vazio.
- Formulários e Validação:
	- Tela de Login: 2 campos com validação (e-mail/usuário e senha) usando `Form` + `TextFormField` via molécula reutilizável.
	- Tela de Registro: formulário com 7 campos e múltiplos validadores.
	- Tela de Esqueci a Senha: validação de e-mail ou celular.

## Onde encontrar

- Tema e cores: `lib/widgets/shared.dart` (inclui `GlassPanel` e paleta `AppColors`).
- Componentes atômicos: `lib/widgets/atomic_demo.dart` (e a página de demonstração `/atomic-demo`).
- Login (refatorado para Atomic Design): `lib/screens/login_page.dart`.
- Home com microinterações e Hero: `lib/screens/home_page.dart`.
- Detalhes do livro com Hero e Semantics: `lib/screens/book_details_page.dart`.
- Consumo de API com FutureBuilder: `lib/screens/api_demo_page.dart`.

## Dependências

- `google_fonts` para tipografia.
- `http` para requisições REST (adicionado em `pubspec.yaml`).

## Executar o projeto

1. Instale as dependências.
2. Rode o app em um emulador/dispositivo.

## Notas técnicas

- Atomic Design: `AtomButton` encapsula microinterações e acessibilidade; `MoleculeTextField` padroniza campos de entrada (label, ícone, validação, obscureText/keyboardType).
- Acessibilidade: `Semantics` em imagens, botões e mensagens vazias; tooltips nos ícones da `AppBar`.
- API: `FutureBuilder` gerencia estados assíncronos; erros são exibidos de forma amigável.

## Próximos passos sugeridos

- Adicionar estados de loading/disabled nos botões atômicos.
- Internacionalização (i18n) das mensagens.
- Testes widget para validar acessibilidade e interações.
# 📚 Eterna Livraria

A **Eterna Livraria** é um projeto que simula uma plataforma de compra, venda e troca de livros novos e usados.  
O objetivo é oferecer uma experiência simples e intuitiva para que os leitores possam encontrar, anunciar e trocar livros de forma prática.

---

## 🚀 Funcionalidades Implementadas

Atualmente, o projeto conta com as seguintes telas:

- **Login:** acesso ao sistema com credenciais do usuário.  
- **Cadastro:** criação de nova conta para utilização da plataforma.  
- **Esqueci a Senha:** recuperação de acesso através de redefinição de senha.  
- **Catálogo de Livros:** página para visualização dos livros disponíveis na livraria.

---

## 🛠️ Objetivo do Projeto

O aplicativo busca ser a base de uma futura plataforma completa de livraria digital, permitindo:  
- Comprar livros novos e usados.  
- Vender exemplares.  
- Realizar trocas entre usuários.  


## ⚙ Tecnologias e ferramentas

- Flutter (Dart) — SDK compatível com `sdk: ^3.7.0` (ver `pubspec.yaml`)
- Dart (versão conforme `pubspec.yaml`)