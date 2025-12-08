# 🌱 Raiz Digital

Sistema de gerenciamento e rastreabilidade de distribuição de sementes agrícolas para agricultura familiar.

## 📋 Sobre o Projeto

O **Raiz Digital** é um sistema completo para controle de estoque, distribuição e rastreabilidade de sementes agrícolas destinadas a agricultores familiares. O sistema permite gestão eficiente desde a entrada de lotes de sementes até a entrega final aos beneficiários, com controle total da cadeia de distribuição.

---

- [🌱 Raiz Digital](#-raiz-digital)
  - [📋 Sobre o Projeto](#-sobre-o-projeto)
  - [📚 Importância da Modelagem do Banco de Dados](#-importância-da-modelagem-do-banco-de-dados)
  - [📚 Importância da Modelagem do Banco de Dados](#-importância-da-modelagem-do-banco-de-dados-1)
    - [🔹 Modelo Conceitual](#-modelo-conceitual)
    - [🔹 Modelo Lógico](#-modelo-lógico)
    - [🔹 Modelo Físico](#-modelo-físico)
  - [🧩 Normalização e Organização dos Dados](#-normalização-e-organização-dos-dados)
    - [▶ Resultado](#-resultado)
  - [🎯 Funcionalidades Principais](#-funcionalidades-principais)
  - [🗄️ Estrutura do Banco de Dados](#️-estrutura-do-banco-de-dados)
    - [Principais Tabelas](#principais-tabelas)
  - [📊 Modelo de Dados](#-modelo-de-dados)
    - [Principais Relacionamentos](#principais-relacionamentos)
    - [Status do Sistema](#status-do-sistema)
  - [🚀 Instalação](#-instalação)
    - [Pré-requisitos](#pré-requisitos)
    - [Passos para Instalação](#passos-para-instalação)
  - [👥 Perfis de Usuário](#-perfis-de-usuário)
  - [🔍 Funcionalidades de Rastreabilidade](#-funcionalidades-de-rastreabilidade)
  - [📈 Indicadores Disponíveis](#-indicadores-disponíveis)
  - [🔒 Segurança](#-segurança)
  - [🛠️ Recursos Técnicos Implementados](#️-recursos-técnicos-implementados)
    - [Stored Procedures (14)](#stored-procedures-14)
    - [Functions (14)](#functions-14)
    - [Triggers (12)](#triggers-12)
    - [Views (12)](#views-12)
  - [📝 Observações Técnicas](#-observações-técnicas)
  - [🛠️ Manutenção](#️-manutenção)
    - [Backup Recomendado](#backup-recomendado)
    - [Limpeza de Dados Antigos](#limpeza-de-dados-antigos)
    - [Rotina Automatizada](#rotina-automatizada)
  - [📞 Suporte](#-suporte)
  - [📂 Estrutura de Arquivos](#-estrutura-de-arquivos)

---
## 📚 Importância da Modelagem do Banco de Dados
## 📚 Importância da Modelagem do Banco de Dados

A modelagem foi realizada em três etapas fundamentais para garantir robustez, escalabilidade e manutenibilidade:

### 🔹 Modelo Conceitual
Representa a visão do negócio, mostrando as entidades e como elas se relacionam no mundo real. Nesta fase, identificamos:
- **Entidades principais**: Usuários, Espécies, Fornecedores, Armazéns, Municípios, Agricultores, Lotes, Movimentações, Ordens de Expedição, Entregas
- **Relacionamentos**: Como cada entidade interage (ex: Lotes pertencem a Espécies e Fornecedores; Entregas vinculam Ordens a Agricultores)
- **Requisitos do negócio**: Rastreabilidade via QR Code, geolocalização de entregas, controle de validade

Esta etapa ajuda a equipe a entender o sistema antes de qualquer programação.

### 🔹 Modelo Lógico
Transforma o conceito em estrutura relacional, definindo:
- **Atributos de cada entidade**: Campos necessários com tipos apropriados
- **Chaves primárias e estrangeiras**: Garantindo integridade referencial
- **Cardinalidades**: 1:N entre Municípios e Agricultores, N:N entre Ordens e Lotes (via tabela associativa `itens_ordem`)
- **Normalização**: Eliminação de redundâncias e dependências problemáticas

### 🔹 Modelo Físico
Implementação no MySQL, com:
- **Tipos de dados otimizados**: DECIMAL para quantidades, ENUM para status fixos, JSON para logs de auditoria
- **Índices estratégicos**: Em campos de busca frequente (CPF, email, número de lote, datas)
- **Restrições de integridade**: FOREIGN KEYS com ON DELETE CASCADE onde apropriado
- **Regras de negócio**: Triggers para validação e auditoria automática
- **Engine InnoDB**: Suporte a transações ACID

📌 **Essa sequência garante que o banco atenda aos requisitos do cliente sem desperdício de recursos.**

---

## 🧩 Normalização e Organização dos Dados

Durante o desenvolvimento, o banco foi certificado nas **3 Formas Normais (1FN, 2FN e 3FN)**:

| Forma Normal | Benefício |
|--------------|-----------|
| **1FN** | Não há grupos repetidos; cada campo contém valores atômicos (ex: telefone separado de endereço) |
| **2FN** | Evita dependências parciais; dados dependem completamente da chave primária (ex: dados de município não ficam na tabela de agricultores, criando tabela própria) |
| **3FN** | Remove dependências transitivas e redundâncias (ex: nome do fornecedor não fica na tabela de lotes, apenas a chave estrangeira) |

### ▶ Resultado
Um banco **organizado, consistente e livre de duplicações desnecessárias**, com:
- ✅ Redução de anomalias de inserção, atualização e exclusão
- ✅ Facilidade de manutenção e expansão
- ✅ Integridade referencial garantida
- ✅ Performance otimizada com índices apropriados

---

## 🎯 Funcionalidades Principais

- **Gestão de Estoque**: Controle completo de lotes de sementes com rastreabilidade via QR Code
- **Gestão de Armazéns**: Múltiplos armazéns com controle de capacidade e localização
- **Controle de Validade**: Monitoramento automático de datas de validade dos lotes
- **Ordens de Expedição**: Planejamento e controle de distribuições por município
- **Rastreabilidade**: Histórico completo de movimentações e entregas
- **Gestão de Beneficiários**: Cadastro de agricultores e cooperativas
- **Auditoria**: Log completo de operações do sistema
- **Geolocalização**: Registro de coordenadas GPS nas entregas

---

## 🗄️ Estrutura do Banco de Dados

### Principais Tabelas

| Tabela | Descrição |
|--------|-----------|
| `usuarios` | Cadastro de usuários do sistema com perfis de acesso |
| `especies` | Catálogo de espécies de sementes disponíveis |
| `fornecedores` | Registro de fornecedores de sementes |
| `armazens` | Pontos de armazenamento distribuídos |
| `municipios` | Municípios atendidos pelo programa |
| `agricultores` | Beneficiários do programa |
| `lotes` | Lotes de sementes com rastreabilidade |
| `movimentacoes` | Histórico de movimentações de estoque |
| `ordens_expedicao` | Ordens de distribuição de sementes |
| `entregas` | Registro de entregas aos agricultores |
| `auditoria` | Log de auditoria de todas as operações |

---

## 📊 Modelo de Dados

### Principais Relacionamentos

- **Lotes** pertencem a uma Espécie, Fornecedor e Armazém (1:N)
- **Movimentações** registram origem e destino entre Armazéns (N:N via armazém origem/destino)
- **Ordens de Expedição** contêm múltiplos Itens/Lotes (1:N → N:N via `itens_ordem`)
- **Entregas** vinculam Ordens a Agricultores específicos (N:N)
- **Agricultores** pertencem a Municípios (N:1)

### Status do Sistema

**Lotes**:
- `DISPONIVEL`: Pronto para distribuição
- `EM_TRANSITO`: Em transferência
- `VENCIDO`: Fora da validade
- `ESGOTADO`: Sem estoque

**Ordens de Expedição**:
- `PENDENTE`: Aguardando expedição
- `EM_TRANSITO`: Em rota de entrega
- `ENTREGUE`: Concluída
- `CANCELADA`: Cancelada

---

## 🚀 Instalação

### Pré-requisitos

- MySQL 5.7 ou superior
- Acesso com privilégios de criação de banco de dados

### Passos para Instalação

1. Clone ou baixe os arquivos SQL do projeto

2. Execute o script de criação do banco de dados:

```bash
mysql -u seu_usuario -p < criacao_tabelas_bd.sql
```

Ou via cliente MySQL:

```sql
source /caminho/para/criacao_tabelas_bd.sql
```

3. (Opcional) Popule com dados de exemplo:

```bash
mysql -u seu_usuario -p < bd_raiz_digital.sql
```

4. Verifique a criação do banco:

```sql
USE raiz_digital;
SHOW TABLES;
```

---

## 👥 Perfis de Usuário

| Perfil | Permissões |
|--------|-----------|
| **GESTOR** | Acesso completo ao sistema |
| **OPERADOR** | Gestão de estoque e armazéns |
| **AGENTE** | Registro de entregas em campo |
| **CIDADAO** | Consulta de informações públicas |

---

## 🔍 Funcionalidades de Rastreabilidade

- ✅ Código QR único para cada lote
- ✅ Registro de latitude/longitude nas entregas
- ✅ Assinatura digital dos beneficiários
- ✅ Upload de comprovantes
- ✅ Histórico completo de movimentações
- ✅ Log de auditoria com dados antigos e novos (JSON)

---

## 📈 Indicadores Disponíveis

O sistema permite extrair diversos indicadores através de **Views** e **Consultas SQL**:

- Estoque atual por armazém e espécie
- Volume distribuído por município
- Taxa de entregas no prazo
- Perdas por vencimento
- Cobertura de beneficiários
- Histórico de movimentações
- Performance de fornecedores
- Ranking de espécies mais distribuídas

---

## 🔒 Segurança

- 🔐 Senhas armazenadas com hash
- 📝 Log de auditoria completo (INSERT, UPDATE, DELETE)
- 🌐 Registro de IP de origem nas operações
- 👤 Controle de acesso por perfil
- 🔍 Rastreabilidade de todas as operações
- ⚠️ Triggers para validação de regras de negócio

---

## 🛠️ Recursos Técnicos Implementados

### Stored Procedures (14)
Automatização de operações complexas como:
- Registro de login
- Cadastro de espécies
- Processamento automático de vencimento
- Ajustes de estoque
- Transferências entre armazéns

### Functions (14)
Cálculos e validações reutilizáveis:
- Dias para vencimento
- Verificação de disponibilidade
- Capacidade restante de armazéns
- Formatação de dados (CPF, endereços)
- Cálculo de progresso de ordens

### Triggers (12)
Auditoria e validações automáticas:
- Log de todas as operações (INSERT/UPDATE/DELETE)
- Validação de datas de validade
- Atualização automática de status
- Bloqueio de operações inválidas

### Views (12)
Consultas pré-formatadas para relatórios:
- Estoque por armazém
- Lotes próximos ao vencimento
- Distribuição por município
- Dashboard de KPIs

---

## 📝 Observações Técnicas

- **Engine**: InnoDB para suporte a transações ACID
- **Charset**: UTF-8 (suporte completo a português)
- **Timestamps**: Automáticos para rastreabilidade temporal
- **Índices**: Otimizados para consultas frequentes
- **Integridade Referencial**: Foreign Keys com cascade apropriado
- **Soft Delete**: Campo `ativo` para exclusão lógica

---

## 🛠️ Manutenção

### Backup Recomendado

```bash
mysqldump -u usuario -p raiz_digital > backup_raiz_digital_$(date +%Y%m%d).sql
```

### Limpeza de Dados Antigos

Recomenda-se arquivar:
- Registros de auditoria com mais de 2 anos
- Lotes vencidos há mais de 1 ano
- Ordens canceladas antigas

### Rotina Automatizada

Execute diariamente via cron:
```sql
CALL sp_processar_vencimento_lotes();
```

---

## 📞 Suporte

Para dúvidas ou sugestões sobre o sistema, entre em contato com a equipe de desenvolvimento.

---

**Versão do Banco**: 1.0  
**Última Atualização**: 2024  
**SGBD**: MySQL 5.7+  
**Licença**: [Definir conforme necessidade]

---

## 📂 Estrutura de Arquivos

```
raiz-digital/
├── README.md                    # Este arquivo
├── criacao_tabelas_bd.sql       # DDL - Criação de tabelas
└── bd_raiz_digital.sql          # DML + Views + Procedures + Triggers
```

---

**Desenvolvido com 💚 para apoiar a agricultura familiar brasileira**
