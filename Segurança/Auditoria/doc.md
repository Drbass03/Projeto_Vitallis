# Auditoria - Projeto Vitallis

## Visão Geral

O ambiente possui implementação de auditoria em nível de servidor e banco de dados utilizando recursos nativos do SQL Server.

O objetivo da auditoria é monitorar eventos críticos relacionados à autenticação, alterações estruturais, 
permissões e acesso aos dados, permitindo maior rastreabilidade e governança do ambiente.

---

# Auditoria em Nível de Servidor

A auditoria em nível de servidor foi configurada para registrar eventos relacionados à instância do SQL Server, 
incluindo tentativas de autenticação e operações administrativas.

## Eventos Monitorados

- Falhas de login
- Tentativas de autenticação
- Alterações administrativas
- Mudanças em permissões
- Operações relacionadas à segurança do servidor

## Objetivo

A auditoria de servidor permite identificar comportamentos suspeitos, falhas de acesso e alterações administrativas realizadas no ambiente.

Esse tipo de monitoramento auxilia no processo de análise de incidentes e validação de conformidade de segurança.

---

# Auditoria em Nível de Banco de Dados

A auditoria em nível de banco foi implementada para monitorar operações realizadas diretamente no banco de dados do projeto Vitallis.

## Eventos Monitorados

- Alterações de permisões 
- Monitoramento de eventos de (GRANT, REVOKES, DENY)
- Execução de objetos específicos
- Alterações estruturais no banco
- Operações de DELETE e UPDATE em tabelas críticas. 

## Objetivo

O objetivo é garantir rastreabilidade sobre as operações realizadas pelos usuários, permitindo identificar quais ações foram executadas, por quem e em qual momento.

Esse controle é especialmente importante em cenários que envolvem dados clínicos, laboratoriais e informações administrativas.

---

# Estrutura Utilizada

A implementação utiliza os seguintes componentes do SQL Server:

- `SERVER AUDIT`
- `SERVER AUDIT SPECIFICATION`
- `DATABASE AUDIT SPECIFICATION`

Os eventos capturados são armazenados em arquivos de auditoria para posterior consulta e análise.

---

# Validação dos Eventos

Os testes de auditoria foram realizados simulando diferentes contextos de acesso, incluindo usuários administrativos, médicos e perfis com permissões restritas.

Também foram executados cenários de falha de login e operações em tabelas monitoradas para validação da captura correta dos eventos de auditoria.

---

# Scripts de monitoramento e alertas. 

Foram implementados scripts responsáveis pelo monitoramento de ações suspeitas e eventos críticos relacionados à segurança do ambiente.

Essas rotinas são executadas automaticamente por meio do SQL Server Agent e realizam o disparo de alertas para o administrador sempre que comportamentos anômalos, falhas de auditoria ou alterações sensíveis são identificadas.

O objetivo é permitir respostas mais rápidas a possíveis incidentes e fortalecer o controle e a governança do ambiente.

---

#  `sp_audit_change`

Esta procedure é utilizada em um Job do SQL Server Agent responsável por monitorar alterações nas configurações de auditoria e no estado dos arquivos de auditoria do ambiente.

O objetivo é identificar mudanças que possam comprometer a rastreabilidade dos eventos auditados, como desativação da auditoria, 
modificações nas specifications ou falhas relacionadas aos arquivos de armazenamento.

Essa implementação auxilia no fortalecimento da governança e no acompanhamento contínuo dos mecanismos de segurança do projeto. 


