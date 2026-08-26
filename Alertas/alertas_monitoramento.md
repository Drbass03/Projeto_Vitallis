# Alertas de Monitoramento

Este documento descreve os alertas configurados no SQL Server Agent para monitoramento de indicadores relacionados à memória, concorrência e utilização do TempDB.

---

## Page Life Expectancy (PLE)

O **Page Life Expectancy** indica, em segundos, por quanto tempo uma página permanece em média no Buffer Pool antes de ser removida.

Um valor baixo ou uma queda significativa pode indicar aumento na atividade de leitura, churn no Buffer Pool ou possível pressão de memória.

O alerta é configurado para ser disparado quando o PLE ficar abaixo do threshold definido.

### Objetivo

- Identificar possíveis sinais de pressão de memória.
- Detectar quedas relevantes na permanência das páginas no Buffer Pool.
- Notificar o administrador para análise do workload e consumo de memória.

> O PLE deve ser analisado em conjunto com outros indicadores. Um valor isolado abaixo do threshold não representa necessariamente um problema de memória.

---

## Deadlock Detectado

Um **deadlock** ocorre quando duas ou mais sessões bloqueiam recursos umas das outras, formando uma dependência circular.

Quando isso acontece, o SQL Server escolhe uma das transações como vítima, encerra sua execução e permite que as demais continuem.

O alerta monitora o contador:

```text
SQLServer:Locks | Number of Deadlocks/sec
```

Quando um deadlock é identificado, uma notificação é enviada ao operador configurado.

### Objetivo

- Detectar rapidamente a ocorrência de deadlocks.
- Notificar o administrador sobre possíveis problemas de concorrência.
- Permitir investigação posterior das queries e recursos envolvidos.

A captura detalhada dos eventos pode ser complementada posteriormente com **Extended Events**, utilizando eventos como `xml_deadlock_report`.

---

## Crescimento dos Arquivos do TempDB

O TempDB é utilizado por diversas operações internas do SQL Server, incluindo ordenações, operações de hash, tabelas temporárias, version store e outras atividades que necessitam de espaço temporário.

Os arquivos de dados possuem um tamanho inicial planejado. O alerta monitora quando o tamanho total dos arquivos ultrapassa esse baseline, indicando que ocorreu crescimento além da capacidade inicialmente configurada.

### Objetivo

- Detectar crescimento inesperado do TempDB.
- Identificar mudanças no comportamento do workload.
- Chamar atenção para possíveis spills, operações de `SORT` ou `HASH`, uso intensivo de tabelas temporárias ou outras atividades que utilizam espaço temporário.

> O crescimento do TempDB não significa necessariamente que ocorreu um spill. O alerta deve ser tratado como um indicador para investigação.

---

## Controle de Notificações

Os alertas utilizam o parâmetro:

```sql
@delay_between_responses
```

para controlar o intervalo entre notificações.

Esse mecanismo evita o envio excessivo de e-mails quando uma condição permanece ativa por um período prolongado.

Exemplo:

```text
Condição detectada
        ↓
Notificação enviada
        ↓
Cooldown configurado
        ↓
Nova notificação somente após o intervalo definido
```

Isso permite manter a visibilidade de problemas persistentes sem gerar excesso de notificações.
