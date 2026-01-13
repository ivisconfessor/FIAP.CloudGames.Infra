# FIAP CloudGames - Infraestrutura Kubernetes

Repositório de infraestrutura como código (IaC) para orquestração dos microsserviços do projeto FIAP CloudGames no Google Kubernetes Engine (GKE).

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Microsserviços](#microsserviços)
- [Comunicação Assíncrona](#comunicação-assíncrona)
- [Pré-requisitos](#pré-requisitos)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Deploy](#deploy)
- [Configuração](#configuração)
- [Monitoramento](#monitoramento)
- [Tecnologias](#tecnologias)

---

## 🎯 Visão Geral

O FIAP CloudGames faz parte do desafio técnico da PÓS TECH em Arquitetura de Sistemas com .NET

### Objetivos do Projeto

- ✅ Orquestração de containers com Kubernetes
- ✅ Comunicação assíncrona entre microsserviços
- ✅ Imagens Docker otimizadas e seguras
- ✅ Monitoramento e observabilidade
- ✅ Auto scaling baseado em métricas

---

## 🏗️ Arquitetura

### Diagrama de Arquitetura Kubernetes

![Arquitetura FIAP CloudGames no GKE](./docs/imgs/arquitetura-kubernetes.png)

---

## 🔧 Microsserviços

### 1. Usuario API
**Responsabilidade:** Autenticação e gerenciamento de usuários

- **Tecnologia:** .NET 8 (C#)
- **Porta:** 8080
- **Endpoints principais:**
  - `POST /api/v1/usuarios/login` - Autenticação JWT
  - `POST /api/v1/usuarios` - Cadastro de usuários
  - `GET /api/v1/usuarios/{id}` - Consulta de usuário

**Configurações:**
- JWT Issuer: `FIAP.CloudGames.Usuario.API`
- JWT Audience: `FIAP.CloudGames.Client`
- Banco: In-Memory

---

### 2. Jogo API
**Responsabilidade:** CRUD de jogos e busca indexada

- **Tecnologia:** .NET 8 (C#)
- **Porta:** 8080
- **Endpoints principais:**
  - `GET /api/v1/jogos` - Listagem de jogos
  - `POST /api/v1/jogos` - Cadastro de jogo
  - `GET /api/v1/jogos/buscar?termo={termo}` - Busca com Elasticsearch

**Configurações:**
- JWT Issuer: `FIAP.CloudGames.Jogo.API`
- JWT Audience: `FIAP.CloudGames.Client`
- Elasticsearch: `http://elasticsearch-service:9200`
- Banco: In-Memory

---

### 3. Pagamento API
**Responsabilidade:** Processamento de pagamentos

- **Tecnologia:** .NET 8 (C#)
- **Porta:** 8080
- **Endpoints principais:**
  - `POST /api/v1/pagamentos` - Processar pagamento
  - `GET /api/v1/pagamentos/{id}` - Consultar pagamento

**Configurações:**
- JWT Issuer: `FIAP.CloudGames.Pagamento.API`
- JWT Audience: `FIAP.CloudGames.Client`
- Service URLs:
  - Usuario API: `http://34.95.141.115`
  - Jogo API: `http://35.198.10.23`
- Banco: In-Memory

---

## 📡 Comunicação Assíncrona

### Fluxo de Eventos com RabbitMQ
┌─────────────────┐ │ Usuario API │ │ (Autenticação) │ └────────┬────────┘ │ │ Publica evento: UsuarioCriado ▼ ┌────────────┐ │ RabbitMQ │ │ Exchange │ └─────┬──────┘ │ ├──────────────────────┐ │ │ ▼ ▼ ┌──────────┐ ┌──────────────┐ │ Jogo API │ │ Pagamento API│ │ │ │ │ │ Consome: │ │ Consome: │ │ Criar │ │ Criar │ │ Biblioteca│ │ Carteira │ └──────────┘ └──────────────┘

### Eventos Implementados

#### 1. UsuarioCriado
**Publisher:** Usuario API  
**Consumers:** Jogo API, Pagamento API

**Payload:**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">json</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-zcfboh3i8" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-json" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(199, 146, 234)">{</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;usuarioId&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">1</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;email&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;usuario@exemplo.com&quot;</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;dataCriacao&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;2026-01-13T00:00:00Z&quot;</span><span>
</span><span></span><span class="token" style="color:rgb(199, 146, 234)">}</span><span>
</span></code></pre></div>

**Ações:**
- **Jogo API:** Cria biblioteca de jogos vazia para o usuário
- **Pagamento API:** Cria carteira digital com saldo zero

---

#### 2. PagamentoProcessado
**Publisher:** Pagamento API  
**Consumers:** Jogo API, Usuario API

**Payload:**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">json</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-i82ujm05u" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-json" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(199, 146, 234)">{</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;pagamentoId&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">123</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;usuarioId&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">1</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;jogoId&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">5</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;valor&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">59.90</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;status&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;Aprovado&quot;</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;dataProcessamento&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;2026-01-13T02:00:00Z&quot;</span><span>
</span><span></span><span class="token" style="color:rgb(199, 146, 234)">}</span><span>
</span></code></pre></div>

**Ações:**
- **Jogo API:** Adiciona jogo à biblioteca do usuário
- **Usuario API:** Registra histórico de compras

---

#### 3. JogoAdicionado
**Publisher:** Jogo API  
**Consumers:** Elasticsearch (indexação)

**Payload:**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">json</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-e5l0p39r1" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-json" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(199, 146, 234)">{</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;jogoId&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">5</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;nome&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;FIFA 24&quot;</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;descricao&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;Simulador de futebol&quot;</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;preco&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">299.90</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span>
</span><span>  </span><span class="token" style="color:rgb(128, 203, 196)">&quot;tags&quot;</span><span class="token" style="color:rgb(127, 219, 202)">:</span><span> </span><span class="token" style="color:rgb(199, 146, 234)">[</span><span class="token" style="color:rgb(173, 219, 103)">&quot;esporte&quot;</span><span class="token" style="color:rgb(199, 146, 234)">,</span><span> </span><span class="token" style="color:rgb(173, 219, 103)">&quot;multiplayer&quot;</span><span class="token" style="color:rgb(199, 146, 234)">]</span><span>
</span><span></span><span class="token" style="color:rgb(199, 146, 234)">}</span><span>
</span></code></pre></div>

**Ações:**
- **Elasticsearch:** Indexa jogo para busca rápida

---

### Configuração RabbitMQ

**Exchanges:**
- `fiap.cloudgames.usuarios` (tipo: fanout)
- `fiap.cloudgames.pagamentos` (tipo: fanout)
- `fiap.cloudgames.jogos` (tipo: topic)

**Queues:**
- `usuario.criado.jogo-api`
- `usuario.criado.pagamento-api`
- `pagamento.processado.jogo-api`
- `jogo.adicionado.elasticsearch`

**Dead Letter Queue:**
- `dlq.fiap.cloudgames` (retry após 3 tentativas)

---

## 📦 Pré-requisitos

- **Google Cloud Account** com billing ativo
- **gcloud CLI** instalado e configurado
- **kubectl** instalado
- **Docker** (para build local, opcional)
- **Git** para versionamento

---

## 📂 Estrutura de Arquivos do Projeto de Infra
![Estrutura de Arquivos Projeto Infra](./docs/imgs/estrutura-projeto-infra.png)

---

## 🚀 Deploy

### 1. Criar Cluster GKE

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-9rmxbm9va" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span>gcloud container clusters create fiap-cloudgames-cluster </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  </span><span class="token parameter" style="color:rgb(214, 222, 235)">--zone</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span>southamerica-east1-a </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  --num-nodes</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span class="token" style="color:rgb(247, 140, 108)">3</span><span> </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  --machine-type</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span>e2-medium </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  --enable-autoscaling </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  --min-nodes</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span class="token" style="color:rgb(247, 140, 108)">2</span><span> </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  --max-nodes</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span class="token" style="color:rgb(247, 140, 108)">5</span><span>
</span></code></pre></div>

### 2. Configurar kubectl

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-yqbtt49dg" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span>gcloud container clusters get-credentials fiap-cloudgames-cluster </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  </span><span class="token parameter" style="color:rgb(214, 222, 235)">--zone</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span>southamerica-east1-a
</span></code></pre></div>

### 3. Deploy de Infraestrutura

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-7b5rd9z8w" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Elasticsearch</span><span>
</span><span>kubectl apply </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/elasticsearch/
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># RabbitMQ</span><span>
</span><span>kubectl apply </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/rabbitmq/
</span></code></pre></div>

### 4. Deploy das APIs

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-n8lgcn866" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Usuario API</span><span>
</span><span>kubectl apply </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/usuario-api/
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Jogo API</span><span>
</span><span>kubectl apply </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/jogo-api/
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Pagamento API</span><span>
</span><span>kubectl apply </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/pagamento-api/
</span></code></pre></div>

### 5. Verificar Deploy

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-97d6c3242" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Pods</span><span>
</span>kubectl get pods
<!-- -->
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Services</span><span>
</span>kubectl get services
<!-- -->
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># IPs Externos</span><span>
</span><span>kubectl get services </span><span class="token" style="color:rgb(127, 219, 202)">|</span><span> </span><span class="token" style="color:rgb(130, 170, 255)">grep</span><span> LoadBalancer
</span></code></pre></div>

---

## ⚙️ Configuração

### ConfigMaps

Cada API possui um ConfigMap com `appsettings.json`:

**Exemplo: usuario-api-config**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">yaml</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-plws8weyo" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-yaml" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token key" style="color:rgb(255, 203, 139)">apiVersion</span><span class="token" style="color:rgb(199, 146, 234)">:</span><span> v1
</span><span></span><span class="token key" style="color:rgb(255, 203, 139)">kind</span><span class="token" style="color:rgb(199, 146, 234)">:</span><span> ConfigMap
</span><span></span><span class="token key" style="color:rgb(255, 203, 139)">metadata</span><span class="token" style="color:rgb(199, 146, 234)">:</span><span>
</span><span>  </span><span class="token key" style="color:rgb(255, 203, 139)">name</span><span class="token" style="color:rgb(199, 146, 234)">:</span><span> usuario</span><span class="token" style="color:rgb(199, 146, 234)">-</span><span>api</span><span class="token" style="color:rgb(199, 146, 234)">-</span><span>config
</span><span></span><span class="token key" style="color:rgb(255, 203, 139)">data</span><span class="token" style="color:rgb(199, 146, 234)">:</span><span>
</span><span>  </span><span class="token key" style="color:rgb(255, 203, 139)">appsettings.json</span><span class="token" style="color:rgb(199, 146, 234)">:</span><span> </span><span class="token" style="color:rgb(199, 146, 234)">|</span><span class="token scalar" style="color:rgb(173, 219, 103)">
</span><span class="token scalar" style="color:rgb(173, 219, 103)">    {
</span><span class="token scalar" style="color:rgb(173, 219, 103)">      &quot;Jwt&quot;: {
</span><span class="token scalar" style="color:rgb(173, 219, 103)">        &quot;Key&quot;: &quot;FIAP_CloudGames_Secret_Key_2024_Min_32_Chars_Long&quot;,
</span><span class="token scalar" style="color:rgb(173, 219, 103)">        &quot;Issuer&quot;: &quot;FIAP.CloudGames.Usuario.API&quot;,
</span><span class="token scalar" style="color:rgb(173, 219, 103)">        &quot;Audience&quot;: &quot;FIAP.CloudGames.Client&quot;,
</span><span class="token scalar" style="color:rgb(173, 219, 103)">        &quot;ExpirationInMinutes&quot;: 60
</span><span class="token scalar" style="color:rgb(173, 219, 103)">      },
</span><span class="token scalar" style="color:rgb(173, 219, 103)">      &quot;ConnectionStrings&quot;: {
</span><span class="token scalar" style="color:rgb(173, 219, 103)">        &quot;DefaultConnection&quot;: &quot;InMemory&quot;
</span><span class="token scalar" style="color:rgb(173, 219, 103)">      }
</span><span class="token scalar" style="color:rgb(173, 219, 103)">    }</span><span>
</span></code></pre></div>

### Sincronização de Chaves JWT

**Chaves utilizadas:**
- **Usuario API:** `FIAP_CloudGames_Secret_Key_2024_Min_32_Chars_Long`
- **Jogo API:** `FIAP_CloudGames_Jogo_Secret_Key_2024_Min_32_Chars_Long`
- **Pagamento API:** Valida tokens com `IssuersKeys` das outras APIs

---

## 📊 Monitoramento

### Elasticsearch

**Acesso interno:**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-i7hundbzn" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span>kubectl port-forward service/elasticsearch-service </span><span class="token" style="color:rgb(247, 140, 108)">9200</span><span>:9200
</span></code></pre></div>

**Health Check:**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-t2xrqfgza" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(130, 170, 255)">curl</span><span> http://localhost:9200/_cluster/health
</span></code></pre></div>

### Logs de Pods

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-qp9coubfg" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Logs em tempo real</span><span>
</span><span>kubectl logs </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> </span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>pod-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span>
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Últimas 100 linhas</span><span>
</span><span>kubectl logs </span><span class="token parameter" style="color:rgb(214, 222, 235)">--tail</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span class="token" style="color:rgb(247, 140, 108)">100</span><span> </span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>pod-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span>
</span></code></pre></div>

### Métricas do Cluster

<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-svn5fa9h7" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span>kubectl </span><span class="token" style="color:rgb(130, 170, 255)">top</span><span> nodes
</span><span>kubectl </span><span class="token" style="color:rgb(130, 170, 255)">top</span><span> pods
</span></code></pre></div>

---

## 🛠️ Tecnologias

### Backend
- **.NET 8** - Framework principal
- **C#** - Linguagem de programação
- **Entity Framework Core** - ORM (In-Memory)
- **JWT Bearer** - Autenticação

### Infraestrutura
- **Google Kubernetes Engine (GKE)** - Orquestração
- **Google Artifact Registry** - Registro de imagens
- **Docker** - Containerização
- **Elasticsearch** - Busca e logs
- **RabbitMQ** - Mensageria assíncrona

### DevOps
- **kubectl** - CLI Kubernetes
- **gcloud** - CLI Google Cloud
- **Cloud Shell** - Ambiente de desenvolvimento

---

## 🐳 Docker

### Imagens Otimizadas

**Características:**
- **Multi-stage build** (build + runtime separados)
- **Base image:** `mcr.microsoft.com/dotnet/aspnet:8.0-alpine`
- **Tamanho:** ~200MB (vs ~500MB padrão)
- **Segurança:** Imagens Alpine com menos vulnerabilidades

**Exemplo Dockerfile:**
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">dockerfile</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-crbqfxnfd" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-dockerfile" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token instruction" style="color:rgb(127, 219, 202)">FROM</span><span class="token instruction"> mcr.microsoft.com/dotnet/sdk:8.0 </span><span class="token instruction" style="color:rgb(127, 219, 202)">AS</span><span class="token instruction"> build</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">WORKDIR</span><span class="token instruction"> /src</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">COPY</span><span class="token instruction"> . .</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">RUN</span><span class="token instruction"> dotnet restore</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">RUN</span><span class="token instruction"> dotnet publish -c Release -o /app/publish</span><span>
</span>
<span></span><span class="token instruction" style="color:rgb(127, 219, 202)">FROM</span><span class="token instruction"> mcr.microsoft.com/dotnet/aspnet:8.0-alpine</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">WORKDIR</span><span class="token instruction"> /app</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">COPY</span><span class="token instruction"> </span><span class="token instruction options" style="color:rgb(128, 203, 196)">--from</span><span class="token instruction options" style="color:rgb(199, 146, 234)">=</span><span class="token instruction options" style="color:rgb(173, 219, 103)">build</span><span class="token instruction"> /app/publish .</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">EXPOSE</span><span class="token instruction"> 8080</span><span>
</span><span></span><span class="token instruction" style="color:rgb(127, 219, 202)">ENTRYPOINT</span><span class="token instruction"> [</span><span class="token instruction" style="color:rgb(173, 219, 103)">&quot;dotnet&quot;</span><span class="token instruction">, </span><span class="token instruction" style="color:rgb(173, 219, 103)">&quot;FIAP.CloudGames.Usuario.API.dll&quot;</span><span class="token instruction">]</span><span>
</span></code></pre></div>

---

## 📝 Comandos Úteis

### Deploy
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-3otq9kv91" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Aplicar todos os manifestos</span><span>
</span><span>kubectl apply </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Reiniciar deployment</span><span>
</span><span>kubectl rollout restart deployment/</span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>deployment-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span>
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Verificar status do rollout</span><span>
</span><span>kubectl rollout status deployment/</span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>deployment-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span>
</span></code></pre></div>

### Debug
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-p55122sa9" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Descrever pod</span><span>
</span><span>kubectl describe pod </span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>pod-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span>
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Executar comando no pod</span><span>
</span><span>kubectl </span><span class="token" style="color:rgb(255, 203, 139)">exec</span><span> </span><span class="token parameter" style="color:rgb(214, 222, 235)">-it</span><span> </span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>pod-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span> -- /bin/sh
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Port forward</span><span>
</span><span>kubectl port-forward service/</span><span class="token" style="color:rgb(127, 219, 202)">&lt;</span><span>service-name</span><span class="token" style="color:rgb(127, 219, 202)">&gt;</span><span> </span><span class="token" style="color:rgb(247, 140, 108)">8080</span><span>:80
</span></code></pre></div>

### Limpeza
<div class="widget code-container remove-before-copy"><div class="code-header non-draggable"><span class="iaf s13 w700 code-language-placeholder">bash</span><div class="code-copy-button"><span class="iaf s13 w500 code-copy-placeholder">Copiar</span><img class="code-copy-icon" src="data:image/svg+xml;utf8,%0A%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2016%2016%22%20fill%3D%22none%22%3E%0A%20%20%3Cpath%20d%3D%22M10.8%208.63V11.57C10.8%2014.02%209.82%2015%207.37%2015H4.43C1.98%2015%201%2014.02%201%2011.57V8.63C1%206.18%201.98%205.2%204.43%205.2H7.37C9.82%205.2%2010.8%206.18%2010.8%208.63Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%20%20%3Cpath%20d%3D%22M15%204.42999V7.36999C15%209.81999%2014.02%2010.8%2011.57%2010.8H10.8V8.62999C10.8%206.17999%209.81995%205.19999%207.36995%205.19999H5.19995V4.42999C5.19995%201.97999%206.17995%200.999992%208.62995%200.999992H11.57C14.02%200.999992%2015%201.97999%2015%204.42999Z%22%20stroke%3D%22%23717C92%22%20stroke-width%3D%221.05%22%20stroke-linecap%3D%22round%22%20stroke-linejoin%3D%22round%22%2F%3E%0A%3C%2Fsvg%3E%0A" /></div></div><pre id="code-bt4t8502s" style="color:white;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;white-space:pre;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none;padding:8px;margin:8px;overflow:auto;background:#011627;width:calc(100% - 8px);border-radius:8px;box-shadow:0px 8px 18px 0px rgba(120, 120, 143, 0.10), 2px 2px 10px 0px rgba(255, 255, 255, 0.30) inset"><code class="language-bash" style="white-space:pre;color:#d6deeb;font-family:Consolas, Monaco, &quot;Andale Mono&quot;, &quot;Ubuntu Mono&quot;, monospace;text-align:left;word-spacing:normal;word-break:normal;word-wrap:normal;line-height:1.5;font-size:1em;-moz-tab-size:4;-o-tab-size:4;tab-size:4;-webkit-hyphens:none;-moz-hyphens:none;-ms-hyphens:none;hyphens:none"><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Deletar todos os recursos</span><span>
</span><span>kubectl delete </span><span class="token parameter" style="color:rgb(214, 222, 235)">-f</span><span> kubernetes/base/
</span>
<span></span><span class="token" style="color:rgb(99, 119, 119);font-style:italic"># Deletar cluster</span><span>
</span><span>gcloud container clusters delete fiap-cloudgames-cluster </span><span class="token" style="color:rgb(199, 146, 234)">\</span><span>
</span><span>  </span><span class="token parameter" style="color:rgb(214, 222, 235)">--zone</span><span class="token" style="color:rgb(127, 219, 202)">=</span><span>southamerica-east1-a
</span></code></pre></div>

---

## 🔗 Links Úteis

- **Repositórios:**
  - [Usuario API](https://github.com/ivisconfessor/FIAP.CloudGames.Usuario.API)
  - [Jogo API](https://github.com/ivisconfessor/FIAP.CloudGames.Jogo.API)
  - [Pagamento API](https://github.com/ivisconfessor/FIAP.CloudGames.Pagamento.API)

- **Documentação:**
  - [Kubernetes](https://kubernetes.io/docs/)
  - [Google Cloud](https://cloud.google.com/docs)
  - [.NET 8](https://learn.microsoft.com/dotnet/)

---

## 👥 Equipe

- **Nome do Grupo:** Grupo 107
- **Participantes:**
  - Discord: @ivisconfessor

---

## 📄 Licença

Este projeto foi desenvolvido como parte do Tech Challenge - Fase 4 da FIAP.

---
