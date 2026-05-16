# Camada de Consultas 

Esta pasta reúne scripts relacionados à camada de acesso a dados do projeto, incluindo:

- Queries
- Views
- Stored Procedures

Esses objetos representam operações típicas de uma aplicação de gestão de atendimentos em uma clínica médica, como consultas de dados, agendamentos e manipulação de informações operacionais.

## Objetivo

O objetivo desta estrutura é simular um cenário real de aplicação, onde o banco de dados atua como backend para consumo de dados por uma aplicação (API, sistema web, Power Apps, etc.).

## Uso de Parâmetros

As **stored procedures** e algumas queries foram desenvolvidas utilizando **parâmetros de entrada**, com os seguintes propósitos:

-  **Reusabilidade**: Permite que os mesmos objetos atendam diferentes cenários
-  **Integração com aplicações**: Simula o recebimento de filtros e entradas vindas da interface do usuário

Exemplo de uso comum:
- Filtrar consultas por paciente
- Buscar agendamentos por data
- Cancelar ou atualizar registros com base em identificadores

## Estrutura dos Scripts

Os scripts estão organizados de forma a representar diferentes responsabilidades:

- **Queries**: Consultas diretas para análise e extração de dados
- **Views**: Abstração e padronização de consultas complexas
- **Stored Procedures**: Encapsulamento de regras de negócio e operações com parâmetros

## Contexto de Uso

Os scripts foram desenvolvidos com foco em:

- Simulação de ambiente real de produção
- Boas práticas de desenvolvimento em T-SQL
- Clareza e organização para fins de portfólio




