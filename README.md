# 🌌 StoryTeller

Sistema interativo de geração de histórias, personagens e cenas utilizando Elixir + Beam + Gemini API.

## 📍 Roadmap

* [ ] Agentificação de personagens e elementos dinâmicos das cenas (NPCs, itens, clima)
* [ ] Persistência e restauração das histórias geradas

## 🚀 Instalação

1. Crie um arquivo `.env` com sua chave da API Gemini:

```bash
GEMINI_API_KEY=coloque_sua_chave_aqui
```

Obtenha sua chave em: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

2. Inicie o projeto Phoenix:

```bash
mix setup
iex -S mix phx.server
``` 

## 🧪 Execução (modo interativo)

```elixir
StoryTeller.Universe.play_n_turns(2) |> StoryTeller.Universe.print_story()
```

## Execução via mix task
```bash
mix play # executa por padrão 2 turnos
mix play 2 # configura n turnos
```

---

## 📝 Exemplo de História

```elixir
===== TURNO 1 =====

📍 Local: A Clareira do Sussurro Lunar, uma clareira secreta na Floresta Eterna.

📖 Cena:
O ar da floresta antiga vibra com uma energia primordial...
🎭 Ações:
- Lyra: Avança furtivamente...
- Grok: Entra na clareira...
- Seraphina: Levanta seu talismã...

===== TURNO 2 =====

📍 Local: A Clareira do Sussurro Lunar...
🎭 Ações:
- Lyra: Sai de seu esconderijo...
- Grok: Para abruptamente...
- Seraphina: Continua focada...

===== FIM DA HISTÓRIA =====
```

---

## 📜 CHANGELOG

| Data         | Categoria                 | Descrição                                                                                                                                                 |
| ------------ | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `05/08/2025` | 📘 **Melhoria de README** | Documentadas novas tasks `mix play` e `mix package.zip`. Adicionado exemplo direto de uso para execução de história interativa no terminal.               |
| `05/08/2025` | 🧪 **Mix Task: play**     | Criada task `mix play` com suporte a número de turnos como argumento. Gera e exporta a história diretamente para `story_teller.md`.                       |
| `05/08/2025` | 📦 **Mix Task: package.zip**      | Criada task `mix package.zip` que empacota o projeto, excluindo `deps`, `_build`, `.git`, `cover/`, `doc/` e o próprio `.zip`. Ideal para distribuição.   |
| `05/08/2025` | 🔐 **.env Automático**    | Adicionado suporte a carregamento automático de variáveis do `.env` via `DotenvParser` em `runtime.exs`. Protegido por checagem de ambiente e existência. |
| `05/08/2025` | 🔧 **Refatoração JSON**   | A função `Scene.parse/1` agora lida diretamente com blocos JSON, delegando parsing e casting. Reduziu redundância e melhorou legibilidade.                |
| `03/08/2025` | 🛡️ **Rate Limiting** | Implementado controle de cotas para Gemini API (Free Tier): `15 RPM`, `250.000 TPM`, `1.000 RPD`. <br>Adicionada lógica de `clean_state`.          |
| `03/08/2025` | 🧠 **Prompt Cleanup** | Detectada duplicação de conteúdo em `Scene.story`. Agora o histórico é `flattened` e truncado a `@scene_memory = 2`. Dramática economia de tokens. |
| `01/08/2025` | 🎉 **Lançamento MVP** | Primeira versão funcional com geração automática de cenas e ações, usando a API do Gemini 2.5 Flash e renderização em Elixir.                      |
