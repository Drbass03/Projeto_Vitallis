# Scripts de Criação de Tabelas

Esta pasta contém os scripts responsáveis pela criação da estrutura principal do banco de dados.

Os objetos foram organizados utilizando diferentes schemas com o objetivo de segmentar responsabilidades, melhorar a organização do ambiente e facilitar a administração do banco de dados.

---

# Schemas Utilizados

## `sch_pacientes`

Responsável pelo armazenamento das informações relacionadas aos pacientes, incluindo dados cadastrais, contatos, endereço .

## `sch_atendimento`

Contém estruturas relacionadas aos atendimentos clínicos, consultas médicas, agendamentos, e fluxo operacional da clínica.

## `sch_laboratorio`

Agrupa tabelas relacionadas ao setor laboratorial, incluindo pedidos de exames, agendamentos, resultados e controle operacional dos exames realizados.

## `sch_adm`

Responsável por armazenar tabelas relacionadas a adm da clinica como, dados dos médicos, usuários do sistema e dados de convênios aceitos. 

---

# Constraints

As tabelas utilizam constraints para garantir integridade e consistência dos dados, incluindo:

- `PRIMARY KEY`
- `FOREIGN KEY`
- `UNIQUE`
- `CHECK`
- `DEFAULT`

As constraints foram aplicadas para assegurar relacionamentos corretos entre entidades e validação de regras básicas de negócio.

---

# Objetivo

Os scripts desta seção servem como base estrutural do projeto, permitindo a recriação completa do ambiente de banco de dados de forma organizada e padronizada.
